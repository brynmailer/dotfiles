static const char norm_fg[] = "#c5c4c5";
static const char norm_bg[] = "#171517";
static const char norm_border[] = "#514f51";

static const char sel_fg[] = "#c5c4c5";
static const char sel_bg[] = "#992555";
static const char sel_border[] = "#c5c4c5";

static const char urg_fg[] = "#c5c4c5";
static const char urg_bg[] = "#771537";
static const char urg_border[] = "#771537";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
