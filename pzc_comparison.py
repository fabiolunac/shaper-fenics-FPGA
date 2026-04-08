import matplotlib.pyplot as plt
from pathlib import Path
import numpy as np

def twos_complement_to_int(bits):
    valor = int(bits, 2)
    n_bits = len(bits)

    if bits[0] == "1":
        valor -= 1 << n_bits

    return valor

def read_file(arquivo):

    with arquivo.open("r", encoding="utf-8") as f:
        linhas = [linha.strip().split() for linha in f if linha.strip()]

    pzc_out, pzc13_out, adc_out = [], [], []

    for l in linhas[1:]:
        if len(l) != 3:
            continue

        pzc, pzc13, adc = l
        pzc_out.append(twos_complement_to_int(pzc))
        pzc13_out.append(twos_complement_to_int(pzc13))
        adc_out.append(int(adc, 2))

    return pzc_out, pzc13_out, adc_out


def main():
    file = Path(__file__).with_name(f"pzc_comparison.txt")

    pzc_out, pzc13_out, adc_out = read_file(file)

    fig, (ax1, ax2, ax3) = plt.subplots(3, 1, sharex=True)

    ax1.plot(adc_out)
    ax1.axhline(0, color="black", linewidth=0.8, linestyle="--")
    ax1.set_title('ADC Output - Pedestal = 500')

    ax2.plot(pzc_out)
    ax2.axhline(0, color="black", linewidth=0.8, linestyle="--")
    ax2.set_title('PZC Output')

    ax3.plot(pzc13_out)
    ax3.axhline(0, color="black", linewidth=0.8, linestyle="--")
    ax3.set_title('PZC 13b Output')

    plt.tight_layout()
    plt.show()



if __name__ == "__main__":
    main()
