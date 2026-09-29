#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

// Ruído de valor barato. Suficiente para fogo; não é gradient noise de verdade.
static float hash21(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

static float valueNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);          // suavização de Hermite

    float a = hash21(i);
    float b = hash21(i + float2(1.0, 0.0));
    float c = hash21(i + float2(0.0, 1.0));
    float d = hash21(i + float2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Fractal Brownian Motion: soma oitavas de ruído para dar detalhe às chamas.
static float fbm(float2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 5; i++) {
        value += amplitude * valueNoise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// Assinatura exigida por `.colorEffect`:
//   half4 nome(float2 position, half4 color, <argumentos extras>)
// `position` vem em pontos, por isso precisamos de `size` para normalizar.
[[ stitchable ]] half4 fire(float2 position, half4 color, float2 size, float time) {
    float2 uv = position / size;

    // Em `colorEffect` o eixo y cresce para BAIXO: uv.y == 0 é o topo.
    // Somar o tempo faz o padrão caminhar em direção ao topo — a chama sobe.
    float2 p = float2(uv.x * 3.0, uv.y * 3.0 + time * 1.6);
    float n = fbm(p);

    // Mais quente na base (uv.y == 1), apagando em direção ao topo.
    float gradient = uv.y;
    float intensity = clamp(n * gradient * 2.1 - 0.32, 0.0, 1.0);

    const half3 ember = half3(0.55, 0.05, 0.0);
    const half3 flame = half3(1.0,  0.45, 0.05);
    const half3 core  = half3(1.0,  0.95, 0.55);

    half3 rgb = mix(ember, flame, half(smoothstep(0.0, 0.5, intensity)));
    rgb = mix(rgb, core, half(smoothstep(0.55, 1.0, intensity)));

    // SwiftUI espera alpha pré-multiplicado.
    half alpha = half(smoothstep(0.03, 0.35, intensity)) * color.a;
    return half4(rgb * alpha, alpha);
}
