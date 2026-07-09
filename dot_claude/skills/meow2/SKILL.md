---
name: meow2
description: >-
  NTU CSIE 的 meow2 工作站（`ssh meow2`，帳號 b10401006，4×RTX 4090）操作指南。當被要求「上去
  meow2 / 在 CSIE 工作站 / 透過 ssh 到遠端」做任何事時使用 —— 跑 uv/conda/python 任務、GPU
  訓練、看/改遠端檔案、裝套件、清空間、同步資料。涵蓋非互動 ssh 的工具載入陷阱、home 2GB
  quota 與 tmp2 / .symlinks 慣例、GPU 選卡禮儀、conda 研究環境用法。避免 agent 因不熟環境踩雷。
---

# meow2（NTU CSIE 工作站）

`ssh meow2` = `b10401006@meow2.csie.ntu.edu.tw`。**NTU CSIE 大學部專屬**工作站。
- 硬體：4× RTX 4090（各 24 GB）、48 核、125 GB RAM、本地 `/tmp2` 13 TB（RAID0）。
- home = `/home/course/select/b10401006`（NFS，慢、有 quota）；shell = zsh；CUDA 在 `/opt/cuda`。
- 這是**共用機器**，別獨佔資源（見「GPU 禮儀」）。dotfiles 用 chezmoi 管、源自 `github.com/kc0506/dotfiles`。

---

## ⚠️ 頭號雷：非互動 ssh 只載入 `.zshenv`

zsh 啟動檔：**非互動非登入 shell（`ssh meow2 'cmd'` 就是這種）只讀 `.zshenv`**；`.zshrc`（含 `mise activate`、conda/mamba init、`/opt/cuda` PATH、alias）**只給互動 shell**。所以裸 `ssh meow2 'python …'` 曾經拿到系統 `/usr/bin/python`、`uv`/`mamba` 直接 not found。

現況（`.zshenv` 已加 mise shims）——依需求選調用方式：

**A. mise 工具 → 直接可用**，不用任何 wrapper：
```bash
ssh meow2 'uv --version'          # ✅ uv python node nvim rg fd gh just uvx pnpm 都直接能用
ssh meow2 'cd ~/tmp2/ev-project && uv run python foo.py'
```

**B. 要 conda/mamba 環境、alias、或 `/opt/cuda` → 先 source 完整互動環境**（推薦，輸出乾淨）：
```bash
ssh meow2 'source ~/.zshrc >/dev/null 2>&1; conda activate physdreamer; python train.py'
```
`>/dev/null 2>&1` 只吞掉 source `.zshrc` 當下的雜訊；之後命令的 stdout/stderr 照常。這一招等同「用戶登入後的完整環境」。

**C. 只想跑某個 conda 環境的 python → 直接用絕對路徑**（最輕、免 activate）：
```bash
ssh meow2 '~/miniforge3/envs/physdreamer/bin/python train.py'
```

> 別用 `ssh meow2 'zsh -ic "…"'`：`-i` 會觸發 oh-my-zsh compinit，噴一個 `.zcompdump` parse error 和日期 banner 到 stderr（功能正常但很吵）。要完整環境就用 B 的 `source ~/.zshrc`。

---

## 檔案該放哪：home 2 GB 硬 quota

- **home（NFS）大學部只有 2 GB**，一超過整個 home 變 **read-only**，任務會離奇壞掉。所以**任何會長大的東西都不准放 home**：資料集、模型權重、快取、build 產物、venv、conda env。
- **一律放 `~/tmp2/`**（→ `/tmp2/b10401006`，本地快碟）。這是所有工作的根據地。
- **`.symlinks` 技巧**：home 裡許多 dotdir 其實是 symlink 指到 `~/tmp2/.symlinks/*`，把快取搬離 2 GB home：`.cache .cargo .rustup .npm .gnupg .vscode-server .mutagen .triton .nv miniforge3` 等。
  **裝新工具若會在 home 建大快取，比照辦理**：
  ```bash
  ssh meow2 'mkdir -p ~/tmp2/.symlinks/.foo && ln -sfn ~/tmp2/.symlinks/.foo ~/.foo'
  ```
- 已就緒的快取重導：`UV_CACHE_DIR`、pip、HF（`~/tmp2/.hf`）、conda pkgs 都已在 tmp2；`~/.cache` symlink 也在 tmp2，所以非互動跑 `uv`/`pip` 快取不會撐爆 home。
- `/tmp2` **不保證可靠（RAID0）、會定期清、快滿時會停你寫入**。當暫存用，重要產物要往 git / 外部備份。查空間：`ssh meow2 'df -h /tmp2'`、查 home quota：`ssh meow2 'quota -s'`。

---

## Python 環境

- **首選 uv**（mise 提供，非互動直接可用）。專案多是 per-project `~/tmp2/<proj>/.venv` + `pyproject.toml`：`cd` 進去 `uv run …` / `uv sync`。
- **研究專案多用 conda 環境**（miniforge3，`.condarc` 設 `auto_activate_base: false`）。列出：`ssh meow2 'ls ~/miniforge3/envs'`。現有含 `physdreamer gic genphys-diff physgaussian kernelbench-agent ev_* cv_hw2_py38 …`。跑法見上面 B / C。
- **不要 `pip install` 到系統 python**；也別在互動 base env 亂裝。

---

## GPU 禮儀（重要，共用機器）

用戶明確要求：**別獨佔別人正在用的 GPU**。

1. 先看誰在用：`ssh meow2 'nvidia-smi --query-gpu=index,memory.used,utilization.gpu --format=csv'`
2. 挑**空的卡**（memory.used ≈ 0），用 `CUDA_VISIBLE_DEVICES` 綁定：
   ```bash
   ssh meow2 'source ~/.zshrc >/dev/null 2>&1; CUDA_VISIBLE_DEVICES=1 conda activate physdreamer; python train.py'
   ```
3. 4 張卡不要全吃；大 job 前若卡都在忙，先問用戶或等。
4. 工作站整體負載可看 `monitor.csie.ntu.edu.tw`。CSIE 規範：GPU 機器每人上限約 1600% CPU / 30 GB RAM，異常用量會被直接砍 process 並短暫停權。

---

## 長任務 / 破壞性操作

- **長任務用 `tmux`（`/usr/bin/tmux`）或 zellij（mise）detach**，別讓它綁在 ssh 連線上。例：`ssh meow2 'tmux new -d -s train "source ~/.zshrc >/dev/null 2>&1; CUDA_VISIBLE_DEVICES=2 python train.py |& tee ~/tmp2/<proj>/train.log"'`。
- **刪檔要謹慎**：用戶互動 shell 有 `del`（移到 `~/trash`）取代 `rm`，但**非互動 ssh 沒有這個函數**。刪東西前先確認路徑；`~/trash` 也吃 home quota，清完記得清 trash。
- **給長跑程式有意義的名字**（CSIE 規範，別叫 `a.out`）。
- git identity 已設好（kc0506 / kchong0506@gmail.com）；`~/tmp2` 底下多數專案是 git repo。

---

## 專案地圖（以 `ssh meow2 'ls ~/tmp2'` 為準）

`~/tmp2/` 底下：研究主線 **`ev-project/generative-phys`**（PhysDreamer 相關，核心新工作、**無 GitHub remote**，靠 mutagen 備份）、`PhysDreamer`（資料在 `PhysDreamer/data`）、`PhysGaussian`、`gic*`；另有 `triton*`、`pytorch`、`KernelBench`、`ntuh`、`mednote`、`ocr-spike`、`competitions`、各種 `ev-hw*` 課程作業等。

本機 `~/main/meow2/` 是部分鏡像：code 走 mutagen 雙向同步、`PhysDreamer/data` 走 rsync（見本機 `scripts/`）。要動這些同步機制前先查相關 memory（`project-meow2-sync`）。

---

## 快速自檢（上去做事前可先跑）

```bash
ssh meow2 'source ~/.zshrc >/dev/null 2>&1; \
  echo "host=$(hostname)"; \
  nvidia-smi --query-gpu=index,memory.used,utilization.gpu --format=csv; \
  df -h /tmp2 | tail -1; quota -s 2>/dev/null | tail -1'
```
