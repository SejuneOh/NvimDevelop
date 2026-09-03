return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    -- 별칭과 경로를 잇는 구분자. 퀵 메뉴에서 줄을 직접 편집할 때도 이 문자열로 나눈다.
    local SEP = "  ::  "

    local function split_alias(str)
      local alias, path = str:match("^(.-)" .. vim.pesc(SEP) .. "(.+)$")
      if alias then
        return vim.trim(alias), vim.trim(path)
      end
      return nil, vim.trim(str)
    end

    local default_create_list_item =
      require("harpoon.config").get_default_config().default.create_list_item

    harpoon:setup({
      default = {
        display = function(item)
          local alias = item.context and item.context.alias
          if alias and alias ~= "" then
            return alias .. SEP .. item.value
          end
          return item.value
        end,
        create_list_item = function(config, name)
          local alias
          if type(name) == "string" then
            alias, name = split_alias(name)
          end
          local item = default_create_list_item(config, name)
          if alias then
            item.context.alias = alias
          end
          return item
        end,
      },
    })

    -- 파일 추가 / 메뉴 토글
    vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end,
      { desc = "Harpoon: 현재 파일 추가" })
    vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
      { desc = "Harpoon: 메뉴 토글" })

    -- 별칭을 입력받아 현재 파일 추가
    vim.keymap.set("n", "<leader>hA", function()
      vim.ui.input({ prompt = "Harpoon alias: " }, function(alias)
        if not alias or alias == "" then
          return
        end
        local list = harpoon:list()
        list:add()
        local item = list.items[list._length]
        if item then
          item.context.alias = alias
        end
      end)
    end, { desc = "Harpoon: 별칭 붙여 현재 파일 추가" })

    -- 슬롯 1~4로 빠른 점프
    vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon: 슬롯 1" })
    vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon: 슬롯 2" })
    vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon: 슬롯 3" })
    vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon: 슬롯 4" })

    -- 이전/다음 슬롯
    vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Harpoon: 이전 슬롯" })
    vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Harpoon: 다음 슬롯" })
  end,
}
