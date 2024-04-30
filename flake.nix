{
  description = "A flake implementation of the Pomatez AppImage";

  outputs = { self, nixpkgs, flake-utils, ... }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        pname = "pomatez";
        version = "1.6.4";
        name = "${pname}-${version}";

        src = pkgs.fetchurl {
          url = "https://github.com/zidoro/pomatez/releases/download/v1.6.4/Pomatez-v1.6.4-linux-x86_64.AppImage";
          sha256 = "a8701419dc777eb01f6c80d32b8c1b22b10a40c4d946c72aa13cb8bca3ee801f";
        };

        appimageContents = pkgs.appimageTools.extractType2 {inherit name src;};

        Pomatez = pkgs.appimageTools.wrapType2 rec {
          inherit name src;

          extraInstallCommands = ''
            mv $out/bin/${name} $out/bin/${pname}

            install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop

            ${pkgs.imagemagick}/bin/convert ${appimageContents}/${pname}.png -resize 512x512 ${pname}_512.png

            install -m 444 -D ${pname}_512.png $out/share/icons/hicolor/512x512/apps/${pname}.png

            substituteInPlace $out/share/applications/${pname}.desktop \
              --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
          '';

          meta = with pkgs.lib; {
            description = "Stay Focused. Take a Break.";
            homepage = "https://github.com/pomatez/releases";
            license = licenses.mit;
            platforms = ["x86_64-linux"];
            mainProgram = "Pomatez";
          };
        };
      in
      {
        packages = {
          default = Pomatez;
        };
      }
    );
}
