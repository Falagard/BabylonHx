package com.babylonhx.engine.graphics.pipeline;

/**
 * Enumeration of blend factors for alpha blending
 */
enum BlendFactor {
    ZERO;
    ONE;
    SRC_COLOR;
    ONE_MINUS_SRC_COLOR;
    DST_COLOR;
    ONE_MINUS_DST_COLOR;
    SRC_ALPHA;
    ONE_MINUS_SRC_ALPHA;
    DST_ALPHA;
    ONE_MINUS_DST_ALPHA;
    SRC_ALPHA_SATURATE;
    CONSTANT_COLOR;
    ONE_MINUS_CONSTANT_COLOR;
    CONSTANT_ALPHA;
    ONE_MINUS_CONSTANT_ALPHA;
}

/**
 * Enumeration of blend operations
 */
enum BlendOp {
    ADD;
    SUBTRACT;
    REVERSE_SUBTRACT;
    MIN;
    MAX;
}

/**
 * Enumeration of comparison functions
 */
enum CompareOp {
    NEVER;
    LESS;
    EQUAL;
    LESS_OR_EQUAL;
    GREATER;
    NOT_EQUAL;
    GREATER_OR_EQUAL;
    ALWAYS;
}

/**
 * Enumeration of face culling modes
 */
enum CullMode {
    NONE;
    FRONT;
    BACK;
    FRONT_AND_BACK;
}

/**
 * Enumeration of polygon fill modes
 */
enum PolygonMode {
    FILL;
    LINE;
    POINT;
}

/**
 * Enumeration of front face orientation
 */
enum FrontFace {
    COUNTER_CLOCKWISE;
    CLOCKWISE;
}

/**
 * Enumeration of stencil operations
 */
enum StencilOp {
    KEEP;
    ZERO;
    REPLACE;
    INCREMENT_AND_CLAMP;
    DECREMENT_AND_CLAMP;
    INVERT;
    INCREMENT_AND_WRAP;
    DECREMENT_AND_WRAP;
}
