-- lazy.nvim에서 `import = "lazyvim-ko.plugins"`로 불러오는 설정 조각.
-- which-key와 snacks.nvim 설정에 번역 훅만 끼워 넣는다. 두 플러그인을 새로 설치하지는 않는다(optional).
return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function()
      require("lazyvim-ko").attach_which_key()
    end,
  },
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      local ko = require("lazyvim-ko")
      ko.patch_dashboard_opts(opts)
      ko.patch_dashboard_startup()
    end,
  },
}
