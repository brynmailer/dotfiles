const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#171517", /* black   */
  [1] = "#771537", /* red     */
  [2] = "#992555", /* green   */
  [3] = "#ba1e45", /* yellow  */
  [4] = "#d02b5b", /* blue    */
  [5] = "#e4567d", /* magenta */
  [6] = "#df76a8", /* cyan    */
  [7] = "#c5c4c5", /* white   */

  /* 8 bright colors */
  [8]  = "#514f51",  /* black   */
  [9]  = "#771537",  /* red     */
  [10] = "#992555", /* green   */
  [11] = "#ba1e45", /* yellow  */
  [12] = "#d02b5b", /* blue    */
  [13] = "#e4567d", /* magenta */
  [14] = "#df76a8", /* cyan    */
  [15] = "#c5c4c5", /* white   */

  /* special colors */
  [256] = "#171517", /* background */
  [257] = "#c5c4c5", /* foreground */
  [258] = "#c5c4c5",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
