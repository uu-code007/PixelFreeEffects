#ifndef PF_COLOR_GRADING_PARAMS_H
#define PF_COLOR_GRADING_PARAMS_H

#include <stdint.h>

#define PF_COLOR_GRADING_MAX_CUSTOM_HSL 16
#define PF_COLOR_GRADING_MAX_CURVE_POINTS 32

typedef struct PFColorGradingCurvePoint {
    float x;
    float y;
} PFColorGradingCurvePoint;

typedef struct PFColorGradingCurve {
    int count; /* 0 = identity; otherwise 2..32, increasing x, coordinates 0..1. */
    PFColorGradingCurvePoint points[PF_COLOR_GRADING_MAX_CURVE_POINTS];
} PFColorGradingCurve;

typedef struct PFColorGradingCustomHSL {
    float keyColor[3]; /* RGB 0..1; selects hue, not exact RGB distance. */
    float range;       /* Inner half-width in turns, 0..0.5. */
    float feather;     /* Outer transition width in turns, 0..0.5-range. */
    float hue;         /* -1..1; 0 is neutral. */
    float saturation;  /* -1..1; 0 is neutral. */
    float lightness;   /* -1..1; 0 is neutral. */
} PFColorGradingCustomHSL;

typedef struct PFColorGradingParams {
    /* Signed controls: -1..1, neutral 0. Unsigned controls are marked below. */
    float brightness;
    float contrast;
    float saturation;
    float vibrance;
    float ambiance;
    float clarity;
    float structure;
    float sharpen; /* 0..1 */
    float denoise; /* 0..1 */
    float exposure;
    float lightSensation;
    float highlights;
    float shadows;
    float blacks;
    float whites;
    float fade; /* 0..1 */
    float vignette;
    float glow; /* 0..1 */
    float temperature;
    float tint;
    float hue;
    float splitShadow[4]; /* RGBA 0..1 */
    float splitHighlight[4]; /* RGBA 0..1 */
    float splitShadowIntensity; /* 0..1 */
    float splitHighlightIntensity; /* 0..1 */
    float grainIntensity; /* 0..1 */
    float grainRough; /* 0..1 */
    /* Red, orange, yellow, green, cyan, blue, purple, magenta; -1..1. */
    float hslHue[8];
    float hslSat[8];
    float hslLight[8];
    int customHSLCount;
    PFColorGradingCustomHSL customHSL[PF_COLOR_GRADING_MAX_CUSTOM_HSL];
    PFColorGradingCurve curveRGB;
    PFColorGradingCurve curveRed;
    PFColorGradingCurve curveGreen;
    PFColorGradingCurve curveBlue;
} PFColorGradingParams;

typedef enum PFColorGradingError {
    PFColorGradingErrorInvalidArgument = -200,
    PFColorGradingErrorUnauthorized = -201,
    PFColorGradingErrorGL = -202,
    PFColorGradingErrorMissingResource = -203
} PFColorGradingError;

#endif
