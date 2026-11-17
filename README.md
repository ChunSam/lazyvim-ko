# lazyvim-ko

LazyVim의 **단축키 메뉴(which-key)** 와 **시작 화면(대시보드)** 을 한국어로 보여 주는 패치입니다.

> LazyVim 공식 프로젝트가 아닌 개인이 만든 비공식 패치입니다. 문제가 생기면 LazyVim 쪽이 아니라 이 저장소에 이슈를 남겨 주세요.

```
╭ 󱁐  » +화면 ──────────────────────────────╮
│ a ➜  애니메이션 끄기                     │
│ b ➜  어두운 배경 끄기                    │
│ C ➜ 󱥰 색 테마                             │
│ d ➜  진단 끄기                           │
│ s ➜  맞춤법 검사 켜기                    │
│ w ➜  줄 바꿈 켜기                        │
╰──────────────────────────────────────────╯
```

## 번역 범위

| 화면 | 번역 |
|---|---|
| `Space`, `g`, `z`, `[`, `]`, `Ctrl-w` 등을 눌렀을 때 뜨는 단축키 메뉴 | ✅ |
| 시작 화면 항목과 맨 아래 "플러그인 N개를 Nms 만에 불러왔어요" 줄 | ✅ |
| `:Lazy`, `:LazyExtras`, `:Mason` 화면, 알림 메시지, Neovim 오류 메시지 | ❌ (영어 그대로) |

LazyVim 기본 기능, LazyVim이 쓰는 플러그인, which-key 기본 프리셋, Neovim 기본 단축키의 문구 약 450개가 들어 있습니다.
사전에 없는 문구는 영어로 그대로 나옵니다.

## 설치

`~/.config/nvim/lua/plugins/lazyvim-ko.lua` 파일을 만들고 아래 내용을 넣습니다.

```lua
return {
  { "ChunSam/lazyvim-ko", import = "lazyvim-ko.plugins" },
}
```

내려받은 폴더를 직접 쓰려면 `dir`을 씁니다.

```lua
return {
  { dir = "~/Projects/lazyvim-ko", import = "lazyvim-ko.plugins" },
}
```

끄려면 이 파일을 지우면 됩니다.

## 동작 방식

원본 플러그인 코드는 고치지 않고, 화면에 그리는 순간에 영어 문구를 사전에서 찾아 바꿉니다.

- **단축키 메뉴**: which-key가 문구를 다듬을 때 쓰는 목록(`replace.desc`) 맨 뒤에 번역 함수를 붙입니다.
- **시작 화면**: snacks 대시보드의 항목 이름 표시 방식(`dashboard.formats.desc`)을 번역 함수로 바꿉니다.
- **켜기/끄기 항목**: `Enable Spelling` → `맞춤법 검사 켜기`처럼 이름만 사전에서 찾고 "켜기/끄기"를 붙입니다.

LazyVim이 업데이트되어 영어 문구가 바뀌면 그 항목만 영어로 돌아갈 뿐 화면이 깨지지는 않습니다.

## 파일

| 파일 | 내용 |
|---|---|
| `lua/lazyvim-ko/dict.lua` | 영어 → 한국어 사전. 번역을 고치거나 더할 때는 여기만 고치면 됩니다 |
| `lua/lazyvim-ko/init.lua` | 번역 함수와 which-key·대시보드 연결 코드 |
| `lua/lazyvim-ko/plugins.lua` | lazy.nvim이 불러가는 설정 조각 |
| `scripts/dump.lua` | 지금 메뉴에 보이는 문구를 뽑아 번역 여부를 표시 |

## 번역이 빠진 문구 찾기

LazyVim을 업데이트했거나 추가 기능(Extras)을 켠 뒤에 실행합니다.

```sh
cd ~/Projects/lazyvim-ko
nvim --headless +'lua vim.defer_fn(function() vim.cmd("doautocmd User VeryLazy"); vim.defer_fn(function() dofile("scripts/dump.lua"); vim.cmd("qa!") end, 300) end, 100)' | grep MISSING
```

`MISSING`으로 나온 문구를 `dict.lua`에 추가하면 됩니다.
LSP나 Git 단축키처럼 파일을 열어야 생기는 메뉴는 이 방법으로 잡히지 않습니다.

## 라이선스

[MIT](LICENSE)
