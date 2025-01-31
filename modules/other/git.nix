{pkgs, ...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    config = {
      user = {
        name = "Marcello Krahforst";
        email = "marcello.2001@hotmail.com";
        signingKey = "";
      };
      init.defaultbranch = "main";
      branch.autosetupmerge = "true";
      merge.stat = "true";
      pull.ff = "only";
      gpg.format = "ssh";
      commit.gpgsign = "true";
      diff.external = "${pkgs.difftastic}/bin/difft";
      core = {
        editor = "hx";
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      feauture = {
        manyFiles = true;
      };
    };
  };
}
