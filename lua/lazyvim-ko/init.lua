-- lazyvim-ko: LazyVim 단축키 메뉴(which-key)와 시작 화면을 한국어로 표시한다.
--
-- 원본 플러그인 코드는 건드리지 않고, 화면에 그리는 순간에 영어 문구를 사전에서 찾아 바꾼다.
-- 사전에 없는 문구는 영어 그대로 둔다(업데이트로 문구가 바뀌어도 깨지지 않는다).

local M = {}

local words = require("lazyvim-ko.dict")
local lower ---@type table<string,string>?

local function lookup(s)
  local hit = words[s]
  if hit then
    return hit
  end
  if not lower then
    lower = {}
    for k, v in pairs(words) do
      lower[k:lower()] = v
    end
  end
  return lower[s:lower()]
end

---@param desc string
---@return string?
local function translate(desc)
  -- which-key 그룹 이름 앞의 "+"
  local s = desc:gsub("^%+", "")
  local hit = lookup(s)
  if hit then
    return hit
  end

  -- 켜고 끄는 항목 (snacks toggle): "Enable Spelling" -> "맞춤법 검사 켜기"
  for en, ko in pairs({ Enable = " 켜기", Disable = " 끄기", Toggle = " 켜기/끄기" }) do
    local name = s:match("^" .. en .. " (.+)$")
    local t = name and lookup(name)
    if t then
      return t .. ko
    end
  end

  -- 설명이 없는 그룹: "3 keymaps" -> "단축키 3개"
  local n = s:match("^(%d+) keymaps?$")
  if n then
    return "단축키 " .. n .. "개"
  end
end

--- 영어 문구를 한국어로 바꾼다. 사전에 없으면 그대로 돌려준다.
---@param desc any
---@return any
function M.t(desc)
  if type(desc) ~= "string" or desc == "" then
    return desc
  end
  return translate(desc) or desc
end

--- 번역이 있는지 확인한다. (scripts/dump.lua에서 빠진 문구를 찾을 때 쓴다)
---@param desc string
function M.has(desc)
  return translate(desc) ~= nil
end

-- which-key ----------------------------------------------------------------

--- which-key의 문구 치환 목록(replace.desc) 맨 뒤에 번역 함수를 붙인다.
--- 기본 정리 규칙("+" 제거 등)이 먼저 돌고 나서 번역된다.
--- which-key 설정이 끝나기 전에 부르면 false를 돌려준다.
function M.hook_which_key()
  local Config = package.loaded["which-key.config"]
  -- options를 그냥 읽으면 which-key가 빈 설정으로 setup을 해버리므로 rawget으로만 본다
  local opts = Config and rawget(Config, "options")
  if not opts then
    return false
  end
  opts.replace = opts.replace or {}
  opts.replace.desc = opts.replace.desc or {}
  for _, fn in ipairs(opts.replace.desc) do
    if fn == M.t then
      return true
    end
  end
  table.insert(opts.replace.desc, M.t)
  return true
end

local wk_waiting = false

--- which-key가 로드된 직후에 번역 함수를 붙이도록 예약한다.
function M.attach_which_key()
  if M.hook_which_key() or wk_waiting then
    return
  end
  wk_waiting = true
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyLoad",
    callback = function(ev)
      if ev.data == "which-key.nvim" then
        M.hook_which_key()
        return true -- 한 번만 실행하고 지운다
      end
    end,
  })
end

-- 시작 화면 (snacks 대시보드) -----------------------------------------------

local ours = setmetatable({}, { __mode = "k" }) ---@type table<function,boolean>

--- 대시보드 항목 이름(desc)을 그릴 때 번역하도록 formats.desc를 바꾼다.
--- (snacks는 formats 값이 진짜 함수일 때만 호출하므로 반드시 function으로 넣는다)
---@param opts table snacks.nvim 설정
function M.patch_dashboard_opts(opts)
  opts.dashboard = opts.dashboard or {}
  opts.dashboard.formats = opts.dashboard.formats or {}
  local prev = opts.dashboard.formats.desc
  if ours[prev] then
    return
  end
  local function format(item, ctx)
    local desc = M.t(item.desc)
    if type(prev) == "function" then
      return prev(vim.tbl_extend("force", item, { desc = desc }), ctx)
    elseif type(prev) == "table" then
      local text = vim.deepcopy(prev)
      text.hl = text.hl or "desc"
      text[1] = (text[1] == nil or text[1] == "%s") and desc or text[1]:format(desc)
      return text
    end
    return { desc, hl = "desc" }
  end
  ours[format] = true
  opts.dashboard.formats.desc = format
end

local startup_patched = false

--- 시작 화면 맨 아래 "Neovim loaded 40/44 plugins in 50ms" 줄을 한국어로 바꾼다.
--- snacks 쪽 구조가 바뀌어서 예상과 다르면 원래 문구를 그대로 둔다.
function M.patch_dashboard_startup()
  if startup_patched then
    return
  end
  local ok, dashboard = pcall(function()
    return require("snacks.dashboard")
  end)
  if not ok or type(dashboard.sections) ~= "table" or type(dashboard.sections.startup) ~= "function" then
    return
  end
  startup_patched = true
  local orig = dashboard.sections.startup
  dashboard.sections.startup = function(o)
    local ret = orig(o)
    local t = type(ret) == "table" and ret.text
    if type(t) == "table" and #t == 4 and type(t[1][1]) == "string" and t[1][1]:find("Neovim loaded ", 1, true) then
      local icon = t[1][1]:gsub("Neovim loaded $", "")
      ret.text = {
        { icon .. "플러그인 ", hl = "footer" },
        t[2], -- "40/44"
        { "개를 ", hl = "footer" },
        t[4], -- "50ms"
        { " 만에 불러왔어요", hl = "footer" },
      }
    end
    return ret
  end
end

return M
