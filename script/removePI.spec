# -*- mode: python -*-
a = Analysis(['removePI.py'],
             pathex=['C:\\Python27\\Scripts'],
             hiddenimports=[],
             hookspath=None,
             runtime_hooks=None)
pyz = PYZ(a.pure)
exe = EXE(pyz,
          a.scripts,
		  a.binaries + [('msvcp100.dll', 'C:\\Windows\\System32\\msvcp100.dll', 'BINARY'), ('msvcr100.dll', 'C:\\Windows\\System32\\msvcr100.dll', 'BINARY')]
		  if sys.platform == 'win32' else a.binaries,
          name='removePI.exe',
          debug=False,
          strip=None,
          upx=True,
          console=True )
coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               strip=None,
               upx=True,
               name='removePI')
