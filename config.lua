local config = {
    MAP_WIDTH = 1000,
    MAP_HEIGH = 1000,

    CELL_WIDTH = 200,
    CELL_HEIGH = 200,

    RANDOM_SEED = os.time(),

    EXPORT_REGION_RID = false,
}

config.blocks = {
    {
        y = 285,
        x = 602,
        w = 200,
        h = 200,
    },
    {
        y = 63,
        x = 91,
        w = 200,
        h = 200,
    },
    {
        y = 741,
        x = 272,
        w = 200,
        h = 200,
    },
}

return config