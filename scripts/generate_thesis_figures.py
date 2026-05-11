from __future__ import annotations

import json
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import torch
from PIL import Image

plt.rcParams["font.sans-serif"] = ["Microsoft YaHei", "SimHei", "Noto Sans CJK SC", "DejaVu Sans"]
plt.rcParams["axes.unicode_minus"] = False


LATEX_ROOT = Path(__file__).resolve().parents[1]
HALFTONING_ROOT = Path(r"D:\GraduationProject\Code\Halftoning")
FIGURE_ROOT = LATEX_ROOT / "graphics" / "thesis"

sys.path.insert(0, str(HALFTONING_ROOT))

from agent.perceptual import perceptual_params_from_config  # noqa: E402
from agent.loss import cssim  # noqa: E402
from agent.val import compute_all_metrics  # noqa: E402
from traditional.models.error_diffusion import error_diffusion  # noqa: E402
from traditional.models.ordered_dithering import ordered_dithering  # noqa: E402
from verify_fix import load_model  # noqa: E402


def _load_grayscale_tensor(image_path: Path) -> torch.Tensor:
    image = Image.open(image_path).convert("L")
    array = np.asarray(image, dtype=np.float32) / 255.0
    return torch.from_numpy(np.ascontiguousarray(array)).unsqueeze(0)


def _spectrum_image(image_2d: np.ndarray) -> np.ndarray:
    fft = np.fft.fftshift(np.fft.fft2(image_2d))
    return np.log10(np.abs(fft) ** 2 + 1e-10)


def _metric_summary(contone: torch.Tensor, halftone: torch.Tensor, *, w_s: float, perceptual_params) -> dict[str, float]:
    metrics = compute_all_metrics(contone, halftone, w_s=w_s, perceptual_params=perceptual_params)
    return {
        "cssim": float(cssim(contone, halftone, perceptual_params=perceptual_params)[0].item()),
        "psnr_gaussian": float(metrics["psnr_gaussian"][0].item()),
        "psnr_nasanen": float(metrics["psnr_nasanen"][0].item()),
        "ssim": float(metrics["ssim"][0].item()),
    }


def generate_fourier_case_figure() -> None:
    config_path = HALFTONING_ROOT / "config" / "config.json"
    baseline_metrics_path = HALFTONING_ROOT / "verification_results" / "traditional_baselines.json"
    with open(config_path, "r", encoding="utf-8") as file:
        config = json.load(file)
    with open(baseline_metrics_path, "r", encoding="utf-8") as file:
        baseline_metrics = json.load(file)

    primary_paths = baseline_metrics["splits"]["primary_small_split"]["paths"]
    image_path = HALFTONING_ROOT / primary_paths[0]

    device = torch.device("cuda" if torch.cuda.is_available() and config.get("cuda", True) else "cpu")
    model = load_model(HALFTONING_ROOT / "halftoning_dev" / "model_last.pth.tar", config, device)
    perceptual_params = perceptual_params_from_config(config)
    w_s = float(config["trainer"].get("w_s", 0.06))

    contone_cpu = _load_grayscale_tensor(image_path)
    contone = contone_cpu.unsqueeze(0).to(device=device, dtype=torch.float32)
    generator = torch.Generator(device=device)
    generator.manual_seed(int(config.get("seed", 0)) + 2026)
    noise = torch.randn(contone.shape, device=device, dtype=contone.dtype, generator=generator)

    with torch.no_grad():
        prob = model(contone, noise_img=noise).clamp(0.0, 1.0)
        rl_halftone = (prob > 0.5).float()

    ordered_halftone_cpu, _ = ordered_dithering(contone_cpu)
    floyd_halftone_cpu, _ = error_diffusion(contone_cpu, kernel_type="floyd-steinberg")
    ordered_halftone = ordered_halftone_cpu.unsqueeze(0).to(device=device, dtype=torch.float32)
    floyd_halftone = floyd_halftone_cpu.unsqueeze(0).to(device=device, dtype=torch.float32)

    panels = [
        ("本文方法", rl_halftone, _metric_summary(contone, rl_halftone, w_s=w_s, perceptual_params=perceptual_params)),
        ("Bayer 有序抖动", ordered_halftone, _metric_summary(contone, ordered_halftone, w_s=w_s, perceptual_params=perceptual_params)),
        ("Floyd-Steinberg 误差扩散", floyd_halftone, _metric_summary(contone, floyd_halftone, w_s=w_s, perceptual_params=perceptual_params)),
    ]

    contone_image = contone_cpu.squeeze(0).numpy()
    fig, axes = plt.subplots(3, 3, figsize=(12, 12))
    for row, (method_name, halftone_tensor, metrics) in enumerate(panels):
        halftone_image = halftone_tensor[0, 0].detach().cpu().numpy()
        spectrum = _spectrum_image(halftone_image)

        axes[row, 0].imshow(contone_image, cmap="gray", vmin=0.0, vmax=1.0)
        axes[row, 0].set_title("输入连续调图像")
        axes[row, 0].axis("off")

        axes[row, 1].imshow(halftone_image, cmap="gray", vmin=0.0, vmax=1.0)
        axes[row, 1].set_title(
            f"{method_name}\nCSSIM={metrics['cssim']:.4f}  G-HVS={metrics['psnr_gaussian']:.2f} dB"
        )
        axes[row, 1].axis("off")

        im = axes[row, 2].imshow(spectrum, cmap="inferno")
        axes[row, 2].set_title("中心化对数傅里叶频谱")
        axes[row, 2].axis("off")
        fig.colorbar(im, ax=axes[row, 2], fraction=0.046, pad=0.04)

    plt.tight_layout()
    output_path = FIGURE_ROOT / "5-6_fourier_spectrum_case_comparison.png"
    fig.savefig(output_path, dpi=180, bbox_inches="tight")
    plt.close(fig)


def generate_metric_comparison_figure() -> None:
    rl_metrics_path = HALFTONING_ROOT / "verification_results" / "test_metrics.json"
    baseline_metrics_path = HALFTONING_ROOT / "verification_results" / "traditional_baselines.json"
    with open(rl_metrics_path, "r", encoding="utf-8") as file:
        rl_metrics = json.load(file)
    with open(baseline_metrics_path, "r", encoding="utf-8") as file:
        baseline_metrics = json.load(file)

    candidate_rl = rl_metrics["paper_candidate_split"]["metrics"]
    candidate_baselines = baseline_metrics["baselines"]

    method_names = ["本文方法", "Bayer 有序抖动", "Floyd-Steinberg"]
    colors = ["#254441", "#D98E04", "#8C3B3B"]
    metric_specs = [
        ("cssim", "CSSIM"),
        ("ssim", "SSIM"),
        ("psnr_gaussian", "Gaussian-HVS PSNR / dB"),
        ("psnr_nasanen", "Nasanen-HVS PSNR / dB"),
    ]

    value_map = {
        "本文方法": candidate_rl,
        "Bayer 有序抖动": candidate_baselines["ordered_dithering"]["paper_candidate_split"]["metrics"],
        "Floyd-Steinberg": candidate_baselines["floyd_steinberg"]["paper_candidate_split"]["metrics"],
    }

    fig, axes = plt.subplots(2, 2, figsize=(12, 8))
    axes = axes.flatten()
    for axis, (metric_key, metric_title) in zip(axes, metric_specs):
        values = [value_map[name][metric_key]["mean"] for name in method_names]
        bars = axis.bar(method_names, values, color=colors, width=0.6)
        axis.set_title(metric_title)
        axis.grid(axis="y", linestyle="--", alpha=0.3)
        axis.tick_params(axis="x", rotation=12)
        for bar, value in zip(bars, values):
            axis.text(
                bar.get_x() + bar.get_width() / 2.0,
                bar.get_height(),
                f"{value:.4f}" if value < 10 else f"{value:.2f}",
                ha="center",
                va="bottom",
                fontsize=9,
            )

    plt.tight_layout()
    output_path = FIGURE_ROOT / "5-7_candidate_metric_comparison.png"
    fig.savefig(output_path, dpi=180, bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    FIGURE_ROOT.mkdir(parents=True, exist_ok=True)
    generate_fourier_case_figure()
    generate_metric_comparison_figure()


if __name__ == "__main__":
    main()