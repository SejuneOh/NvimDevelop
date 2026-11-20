return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  -- 자동완성 뒤 괄호 닫기는 blink.cmp 의 auto_brackets 가 맡는다
  opts = {
    check_ts = true, -- treesitter와 연동
    ts_config = {
      lua = { "string" },
      javascript = { "template_string" },
    },
  },
}
