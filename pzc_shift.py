import matplotlib.pyplot as plt
from pathlib import Path
import numpy as np

def twos_complement_to_int(bits):
    valor = int(bits, 2)
    n_bits = len(bits)

    if bits[0] == "1":
        valor -= 1 << n_bits

    return valor


def main():
    arquivo = Path(__file__).with_name("pzc_comparison.txt")

    with arquivo.open("r", encoding="utf-8") as f:
        linhas = [linha.strip().split() for linha in f if linha.strip()]

    pzc_out, adc_out = [], [], []

    for linha in linhas[1:]:
        if len(linha) != 3:
            continue

        pzc, adc = linha
        pzc_out.append(twos_complement_to_int(pzc))
        adc_out.append(int(adc,2))

    pzc_out = np.array(pzc_out)
    adc_out = np.array(adc_out)

    erro = adc_out - pzc_out

    if False:
        fig, (ax1, ax2, ax3) = plt.subplots(3, 1, sharex=True)

        ax1.plot(adc_out)
        ax1.set_title("ADC output")
        ax1.set_ylabel("Valor")

        ax2.plot(pzc_out)
        ax2.set_title("PZC output")
        ax2.set_xlabel("Amostra")
        ax2.set_ylabel("Valor")

        ax3.plot(pzc12_out)
        ax3.set_title("PZC 12b output")
        ax3.set_xlabel("Amostra")
        ax3.set_ylabel("Valor")

        plt.tight_layout()
        # plt.show()

    if True:
        fig, (ax1, ax3) = plt.subplots(2, 1, sharex=True)

        ax1.plot(adc_out)
        ax1.set_title("ADC output")
        ax1.set_ylabel("Valor")

        ax3.plot(pzc_out)
        ax3.set_title("PZC 13b output")
        ax3.set_xlabel("Amostra")
        ax3.set_ylabel("Valor")

        plt.tight_layout()
        # plt.show()

    if True:
        fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True)

        ax1.plot(adc_out, label='Shaper Output')
        ax1.plot(pzc_out, label='PZC 13 bits')
        ax1.legend()
        ax1.set_title('Signal Comparison')

        ax2.plot(erro)
        ax2.set_title('Error')
        

        # plt.show

    plt.show()
if __name__ == "__main__":
    main()
