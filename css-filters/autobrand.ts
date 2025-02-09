import * as vec from "./vec.ts";
import { Vec, Operator } from "./vec.ts";
import { flipHueInHYZPrime } from "./color.ts";

export const autoBrandEasy = (
    sourceRGB: [Vec, Vec],
    targetRGB: [Vec, Vec]): Operator => 
{
    const sourceVector = vec.subtract(sourceRGB[1], sourceRGB[0]);
    const targetVector = vec.subtract(targetRGB[1], targetRGB[0]);
    const diff = vec.subtract(targetVector, sourceVector);
    return (input: Vec) => {
        input = vec.subtract(input, sourceRGB[0]);
        input = [input[0] / sourceVector[0] * targetVector[0],
                 input[1] / sourceVector[1] * targetVector[1],
                 input[2] / sourceVector[2] * targetVector[2]];
        input = vec.add(input, targetRGB[0]);
        return input;
    }
}

export const autoBrand = (
    sourceRGB: [Vec, Vec],
    targetRGB: [Vec, Vec]): Operator => 
{
    const flipHue = (input: Vec) => {
        const { r, g, b } = flipHueInHYZPrime(input[0], input[1], input[2]);
        return [r, g, b];
    }
    const sourceVector = vec.subtract(sourceRGB[1], sourceRGB[0]);
    const targetVector = vec.subtract(targetRGB[1], targetRGB[0]);
    const diff = vec.subtract(targetVector, sourceVector);
    const dotProduct = vec.dotProduct(sourceVector, targetVector);
    if (dotProduct > 0) {
        return autoBrandEasy(sourceRGB, targetRGB);
    } else {
        const sourceFlipped = sourceRGB.map(flipHue) as [Vec, Vec];
        const targetFlipped = targetRGB.map(flipHue) as [Vec, Vec];
        const flippedAutoBrand = autoBrandEasy(sourceFlipped, targetFlipped);
        return (input: Vec) => flipHue(flippedAutoBrand(input));
    }
}

export const filterEntry = (operator: Operator) => {
    const matrix = vec.matrixFromOperator(operator);

    // the matrix given from matrixFromOperator is a 4x4 matrix in RGBW transposed
    // from what the SVG filter expects. We need to transpose it back.
    // In addition, SVG filters expect a matrix in RGBAW order, so we need to
    // add the alpha channel entries
    const newMatrix: number[][] = [];
    for (let i = 0; i < 4; ++i) {
        const row: number[] = [];
        for (let j = 0; j < 4; ++j) {
            if (j === 3) {
                // push the alpha channel column
                row.push(0);
            }
            row.push(matrix[j][i]);
        }
        newMatrix.push(row);
    }

    const matrixString = newMatrix.map(row => row.join(" ")).join("   ");
    return `<feColorMatrix in="sourceGraphic" type="matrix" values="${matrixString}" />`;
}

export const svgFilter = (filterName: string, className: string, operator: Operator) => {
    return `<svg class="defs-only"><filter id="${filterName}">${filterEntry(operator)}</filter></svg><style>.${className} { filter: url(#${filterName}) } </style>`;
}