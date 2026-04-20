#pragma once
#include <vector>
#include <array>
#include <cmath>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

static constexpr int RS_L     = 2;
static constexpr int RS_M     = 3;
static constexpr int RS_K     = 16;
static constexpr int RS_NTAPS = RS_L * RS_K;

static double RS_I0(double x) {
    double s = 1.0, t = 1.0, hx = x * 0.5;
    for (int k = 1; k <= 25; k++) {
        double r = hx / k; t *= r * r; s += t;
        if (t < s * 1e-12) break;
    }
    return s;
}

static double RS_Kaiser(int n, double beta) {
    double r = 2.0 * n / (RS_NTAPS - 1) - 1.0;
    return RS_I0(beta * std::sqrt(1.0 - r * r)) / RS_I0(beta);
}

static std::array<float, RS_NTAPS> RS_BuildCoeffs() {
    constexpr double BETA = 6.0;
    std::array<float, RS_NTAPS> h{};
    double centre = (RS_NTAPS - 1) * 0.5;
    for (int i = 0; i < RS_NTAPS; i++) {
        double t = (i - centre) / RS_L;
        double sinc = (std::abs(t) < 1e-9) ? 1.0 : std::sin(M_PI * t) / (M_PI * t);
        h[i] = (float)(sinc * RS_Kaiser(i, BETA));
    }
    for (int p = 0; p < RS_L; p++) {
        float sum = 0.f;
        for (int k = 0; k < RS_K; k++) sum += h[p + k * RS_L];
        if (sum > 0.f)
            for (int k = 0; k < RS_K; k++) h[p + k * RS_L] /= sum;
    }
    return h;
}

inline void ResamplePolyphase(
    const short* in, int inCount,
    std::vector<float>& out
) {
    static const auto coeffs = RS_BuildCoeffs();
    int outCount = inCount * RS_L / RS_M;
    size_t base = out.size();
    out.resize(base + outCount);
    for (int i = 0; i < outCount; i++) {
        int phase = (i * RS_M) % RS_L;
        int n     = (i * RS_M) / RS_L;
        float acc = 0.f;
        for (int k = 0; k < RS_K; k++) {
            int s = n - RS_K / 2 + k;
            if (s < 0) s = 0; else if (s >= inCount) s = inCount - 1;
            acc += coeffs[phase + k * RS_L] * (float)in[s];
        }
        out[base + i] = acc / 32768.f;
    }
}
