export type Vec = number[];
export type Operator = (vec: Vec) => Vec;

// assumes vec1 and vec2 are of length 3
export const crossProduct = (vec1: Vec, vec2: Vec) => {
    return [
        vec1[1] * vec2[2] - vec1[2] * vec2[1],
        vec1[2] * vec2[0] - vec1[0] * vec2[2],
        vec1[0] * vec2[1] - vec1[1] * vec2[0]
    ];
}

export const dotProduct = (vec1: Vec, vec2: Vec) => {
    let result = 0;
    for (let i = 0; i < vec1.length; ++i) {
        result += vec1[i] * vec2[i];
    }
    return result;
}

export const add = (...vecs: Vec[]) => {
    if (!vecs.length) throw new Error();
    const result = new Array(vecs[0].length);
    for (let i = 0; i < result.length; ++i) {
        result[i] = 0; 
    }
    for (let i = 0; i < vecs.length; ++i) {
        const vec = vecs[i];
        for (let j = 0; j < vec.length; ++j) {
            result[j] += vec[j];
        }
    }
    return result;
}

export const scale = (vec: Vec, amount: number) => vec.map(v => v * amount);

export const rotateAroundAxis = (vec: Vec, axis: Vec, amount: number) => {
    const c = Math.cos(amount);
    const s = Math.sin(amount);
    
    return add(
        scale(vec, c),
        scale(crossProduct(axis, vec), s),
        scale(axis, dotProduct(axis, vec) * (1 - c)));
}

export const matrixFromOperator = (operator: (vec: Vec) => Vec): number[][] => {
    // extract translation term

    const t = operator([0,0,0]);
    const mT = scale(t, -1)
    const x = add(operator([1,0,0]), mT);
    const y = add(operator([0,1,0]), mT);
    const z = add(operator([0,0,1]), mT);

    return [[...x,0],[...y,0],[...z,0],[...t,1]];
}

export const matVecMult = (matrix: number[][], vec: Vec): Vec => {
    return add(scale(matrix[0], vec[0]),
        scale(matrix[1], vec[1]),
        scale(matrix[2], vec[2]),
        matrix[3]);
}

export const matMatMult = (m1: number[][], m2: number[][]): number[][] => {
    const result = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]];
    for (let i = 0; i < 4; ++i) {
        for (let j = 0; j < 4; ++j) {
            for (let k = 0; k < 4; ++k) {
                result[i][j] += m1[k][i] * m2[j][k];
            }
        }
    }
    return result;
}

export const subtract = (v1: Vec, v2: Vec): Vec => {
    return add(v1, scale(v2, -1));
}

export const norm = (v: Vec): number => {
    return Math.sqrt(dotProduct(v, v));
}

export const distance2 = (v1: Vec, v2: Vec): number => {
    const d = add(v1, scale(v2, -1));
    return dotProduct(d, d);
}

export const normalize = (v: Vec): Vec => {
    return scale(v, 1/norm(v));
}

export const project = (v: Vec, onto: Vec): Vec => {
    return scale(onto, dotProduct(v, onto) / dotProduct(onto, onto));
}