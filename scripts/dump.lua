-- 현재 Neovim 설정에서 단축키 메뉴(which-key)와 시작 화면에 실제로 보이는 문구를 뽑는다.
-- 번역이 빠진 문구를 찾을 때 쓴다.
--
--   nvim --headless +'lua vim.defer_fn(function() vim.cmd("doautocmd User VeryLazy"); vim.defer_fn(function() dofile("scripts/dump.lua"); vim.cmd("qa!") end, 300) end, 100)'
--
-- (which-key는 Neovim 시작이 끝난 뒤에 준비되므로 바로 실행하면 안 된다)
--
-- 출력: 한 줄에 하나씩 `종류<TAB>모드<TAB>키<TAB>문구<TAB>번역여부`
--   번역여부: ok = 번역됨, MISSING = 사전에 없음

local ok_t, ko = pcall(require, "lazyvim-ko")
local seen = {}
local rows = {}

local function add(kind, mode, lhs, desc)
  if type(desc) ~= "string" or desc == "" then
    return
  end
  local key = kind .. "\0" .. desc
  if seen[key] then
    return
  end
  seen[key] = true
  local status = "-"
  if ok_t then
    status = ko.has(desc) and "ok" or "MISSING"
  end
  rows[#rows + 1] = table.concat({ kind, mode, lhs or "", desc, status }, "\t")
end

-- 1. which-key 메뉴 트리 (실제 키맵 + LazyVim 그룹 이름 + which-key 기본 프리셋을 합친 결과)
local Buf = require("which-key.buf")
for _, m in ipairs({ "n", "x", "o" }) do
  local mode = Buf.get({ mode = m })
  if mode then
    mode.tree:walk(function(node)
      add("menu", m, node.keys, node.desc)
    end)
  end
end

-- 2. 시작 화면(snacks 대시보드) 항목
local ok_s, Snacks = pcall(require, "snacks")
if ok_s and Snacks.config.dashboard and Snacks.config.dashboard.preset then
  for _, item in ipairs(Snacks.config.dashboard.preset.keys or {}) do
    add("dashboard", "", item.key, item.desc)
  end
end

table.sort(rows)
local out = os.getenv("DUMP_OUT")
local f = out and io.open(out, "w") or io.stdout
for _, r in ipairs(rows) do
  f:write(r, "\n")
end
if out then
  f:close()
end
