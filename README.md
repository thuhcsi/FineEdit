# FineEdit: A Structured Paired Dataset for Controllable TTS

[![Paper](https://img.shields.io/badge/Paper-Interspeech%202026-blue)](https://arxiv.org/abs/2606.19209)
[![Demo](https://img.shields.io/badge/Demo-FineCombo--TTS-orange)](https://thuhcsi.github.io/interspeech2026-FineCombo-TTS)

**FineEdit** is a large-scale, structured paired English speech dataset constructed to support **FineCombo-TTS** (Interspeech 2026). It is specifically designed for learning precise relative acoustic attribute control in text-to-speech synthesis.

Each sample is organized as a triplet: `(source speech, control description, target speech)`. Since the source and target speech differ in only one specific acoustic attribute, it allows the model to learn precise reference-grounded transformations rather than absolute properties.

---

## 📁 Directory Structure & Sources

* **`pair-prosody/`**: JSON metadata for relative prosody control. Built on **LibriTTS-R** with speech rate and pitch modifications.
* **`pair-emotion/`**: JSON metadata for relative emotion control. Built on the **ESD** dataset across 5 emotions.
* **`pair-timbre/`**: JSON metadata for relative timbre control. Built by cross-pairing speakers with similar acoustic profiles using **LibriTTS-P** and **TextrolSpeech** annotations.
* **`code-change-prosody/`**: Parallelized batch processing scripts (FFmpeg + GNU Parallel) used for prosody manipulation.
* **`metadata/`**: Contains the baseline meta-information and speaking style/prosody annotations directly derived from **LibriTTS-R** and **TextrolSpeech**.

---

## 📥 Data Download

Due to GitHub's file size limits, the large **augmented audio files** are hosted on Google Drive. The **text annotations and scripts** are available directly in this repository. For your convenience, the official links to our source datasets are also provided below.

### 1. FineEdit Components
| Component | Format | Source | Download Link |
| :--- | :--- | :--- | :--- |
| **Paired Metadata** | `.json` | GitHub | [Repo](README.md) |
| **Augmentation Scripts** | `.sh` | GitHub | [`code-change-prosody/`](code-change-prosody) |
| **Prosody Audio Pack** | `.tar.gz` | Google Drive | [👉 Download from Google Drive](https://drive.google.com/file/d/1Bczn8XoKEhHaHQyynBDZha4Nj5XclNl7/view?usp=sharing) |

### 2. Upstream Source Datasets
To fully utilize the metadata or replicate the full data environment, you can access the original source datasets here:
* **LibriTTS-R**: [https://www.openslr.org/141/](https://www.openslr.org/141/)
* **LibriTTS-P**: [https://github.com/line/LibriTTS-P](https://github.com/line/LibriTTS-P)
* **TextrolSpeech**: [https://github.com/jishengpeng/TextrolSpeech](https://github.com/jishengpeng/TextrolSpeech)

---

## 📝 Citation

If you find this dataset or project helpful, please cite our Interspeech 2026 paper:

```bibtex
@inproceedings{zhou2026finecombo,
  title={FineCombo-TTS: Collaborative and Precise Controllable Speech Synthesis Using Text Descriptions and Reference Speech},
  author={Zhou, Shuoyi and Zhou, Yixuan and Yang, Peiji and, Hu, Yifan and Zhong, Yicheng and Wang, Zhisheng and Wu, Zhiyong},
  booktitle={Interspeech},
  year={2026}
}