import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.home = self.root / 'home'
        self.repo = self.root / 'repo'
        self.home.mkdir()
        for name in ('git/config', 'shell/profile', 'zed/settings.json'):
            p = self.repo / '.config' / name
            p.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / '.config' / name, p)
        subprocess.run(['git', 'init', '-q', str(self.repo)], check=True)
        subprocess.run(['git', '-C', str(self.repo), 'add', '.config'], check=True)
        self.library = self.root / 'installer-functions.sh'
        self.library.write_text((ROOT / 'installer.sh').read_text().split('case "${1:-}" in')[0])
        self.env = dict(os.environ, HOME=str(self.home), TERM='dumb', SHELL='/bin/zsh',
                        GIT_CONFIG_GLOBAL=str(self.home / '.config/git/gitconfig'),
                        GIT_CONFIG_NOSYSTEM='1')

    def run_installer(self, command):
        script = '. "$1"; REPO="$2"; OS=Darwin; _shellPlugins_() { :; }; ' + command
        subprocess.run(['/bin/bash', '-e', '-c', script, 'test', str(self.library), str(self.repo)],
                       env=self.env, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def test_preserves_identity_and_existing_zed_settings(self):
        old = self.home / '.config/git/gitconfig'
        old.parent.mkdir(parents=True)
        old.write_text('[user]\n name = Example User\n email = example@example.org\n')
        zed = self.home / '.config/zed/settings.json'
        zed.parent.mkdir()
        original = '// personal connections\n{"ssh_connections": [{"host": "mini"}]}\n'
        zed.write_text(original)
        self.run_installer('_shellConfig_; _shellConfig_')
        self.assertEqual(zed.read_text(), original)
        local = old.parent / 'local'
        self.assertEqual(local.stat().st_mode & 0o777, 0o600)
        env = dict(self.env, GIT_CONFIG_GLOBAL=str(old.parent / 'config'))
        identity = subprocess.check_output(['git', 'config', '--get', 'user.email'], env=env, text=True)
        self.assertEqual(identity.strip(), 'example@example.org')
        self.assertFalse(list(self.home.rglob('*.before-*')))

    def test_fresh_install_receives_zed_defaults(self):
        self.run_installer('_syncConfig_')
        self.assertEqual((self.home / '.config/zed/settings.json').read_bytes(),
                         (ROOT / '.config/zed/settings.json').read_bytes())
        self.assertFalse((self.home / '.config/git/local').exists())

    def test_linux_uses_hpc_setup_only(self):
        setup = self.repo / 'HPC_config/setup.sh'
        setup.parent.mkdir()
        setup.write_text('#!/bin/bash\nmkdir -p "$HOME/.config"\nprintf hpc > "$HOME/.config/installed"\n')
        self.run_installer('OS=Linux; _nvim_() { return 99; }; _mainScript_; _update_')
        self.assertEqual((self.home / '.config/installed').read_text(), 'hpc')
        self.assertFalse((self.home / '.config/shell/profile').exists())


if __name__ == '__main__':
    unittest.main()
