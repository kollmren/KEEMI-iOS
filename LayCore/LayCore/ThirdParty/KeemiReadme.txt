Notes to the ThirdParty libs used
--------------------------------------

ZipArchive
--------------------------------------
Used to unizp the downloaded catalogs.
Downloaded from: https://code.google.com/p/ziparchive/
Setup in Xcode:
1. Added ThirdPArty directory as referenced folder
2. Added files within ZipArchive to the LayCore - procject
3. Added libz and libc++ to the LayCoreTest - target
TODO: Why LayCoreTest needs the c++ lib(std::terminate()) but LayCore not???
