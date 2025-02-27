import { Vec } from "./vec.ts";

// Convert linear RGB to XYZ using sRGB matrix and D65 white point
export function rgbToXYZ(r: number, g: number, b: number) {
    // Input is assumed to be linear RGB in [0,1] range
    const x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375;
    const y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750;
    const z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041;
    
    return { x, y, z };
}

// shear X and Z so that the 0,0,0 -> 1,1,1 line gives
// x_prime = 0, y_prime = [0,1], z_prime = 0
function centerXYZ(x: number, y: number, z: number) {
    return {
        xPrime: x - y * 0.95047, 
        yPrime: y, 
        zPrime: z - y * 1.08883
    };
}

function flipHueInXYZPrime(xPrime: number, yPrime: number, zPrime: number) {
    return { xPrime: -xPrime, yPrime, zPrime: -zPrime };
}

function uncenterXYZ(xPrime: number, yPrime: number, zPrime: number) {
    return {
        x: xPrime + yPrime * 0.95047,
        y: yPrime,
        z: zPrime + yPrime * 1.08883
    };
}

export function flipHueInHYZPrime(r: number, g: number, b: number) {
    const { x, y, z } = rgbToXYZ(r, g, b);
    let { xPrime, yPrime, zPrime } = centerXYZ(x, y, z);
    ({ xPrime, yPrime, zPrime } = flipHueInXYZPrime(xPrime, yPrime, zPrime));
    const { x: x2, y: y2, z: z2 } = uncenterXYZ(xPrime, yPrime, zPrime);
    const { r: r2, g: g2, b: b2 } = xyzToRGB(x2, y2, z2);
    return { r: r2, g: g2, b: b2 };
}


export function xyzToRGB(x: number, y: number, z: number) {
    const r = x * 3.2404542 + y * -1.5371385 + z * -0.4985314;
    const g = x * -0.9692660 + y * 1.8760108 + z * 0.0415560;
    const b = x * 0.0556434 + y * -0.2040259 + z * 1.0572252;
    
    return { r, g, b }
}
