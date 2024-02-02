
![circlebar-1](https://github.com/asjadnaqvi/stata-circlebar/assets/38498046/1c9420e0-d824-4918-b3c3-28a3bc83abf3)

![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-circlebar) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-circlebar) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-circlebar) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-circlebar) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-circlebar)

---

[Installation](#Installation) | [Syntax](#Syntax) | [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---

# circlebar v1.31
(02 Feb 2024)

This package allows us to draw bar graphs in Stata organized in polar coordinates.


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC (**v1.3**):

```
ssc install circlebar, replace
```

GitHub (**v1.31**):

```
net install circlebar, from("https://raw.githubusercontent.com/asjadnaqvi/stata-circlebar/main/installation/") replace
```


The `palettes` package is required to run this command:

```
ssc install palettes, replace
ssc install colrspace, replace
```

Even if you have these packages installed, please check for updates: `ado update, update`.

If you want to make a clean figure, then it is advisable to load a clean scheme. These are several available and I personally use the following:

```
ssc install schemepack, replace
set scheme white_tableau  
```

I also prefer narrow fonts in figures with long labels. You can change this as follows:

```
graph set window fontface "Arial Narrow"
```


## Syntax

The syntax for the latest version is as follows:

```stata

circlebar var [if] [in], by(var1) [ stack(var2) ]
                [ radmin(num) radmax(num) circles(num) gap(num) alpha(num) palette(str) nolabels rotatelabel showvalues 
                  nocircles  circtop nolegend range(num) nocirclabels circlabformat(str) circlabsize(str) circlabcolor(str)
                  labcolor(str) rotate(num) lcolor(str) lwidth(str) circcolor(str) circwidth(str)
                  labgap(num) labsize(str) cfill(str) clcolor(str)  clwidth(str) points(num)
                  title(str) subtitle(str) note(str) name(str) saving(str) graphregion(str)                                   
                ]
```

See the help file `help circlebar` for details.

The most basic use is as follows:

```
circlebar variable, by(var1) [stack(var2)]
```

where `var1` and `var2` are the string source and destination variables respectively against which the numerical `variable` is plotted. Please note that `circlebar` stacks the height. Areas should not be used for interpretting the results. This might be implemented in the future.



## Examples

Get the example data from GitHub:

```
use "https://github.com/asjadnaqvi/stata-circlebar/blob/main/data/cbardata.dta?raw=true", clear
```

Let's test the `circlebar` command:

```
circlebar deathspm, by(month) 
```

<img src="/figures/circlebar1.png" width="100%">

```
circlebar deathspm, by(month) nocirclab
```

<img src="/figures/circlebar1_1.png" width="100%">


```
circlebar deathspm, by(month) radmin(0)
```

<img src="/figures/circlebar2.png" width="100%">

```
circlebar deathspm, by(month) gap(0.5)
```

<img src="/figures/circlebar3.png" width="100%">

```
circlebar deathspm, by(month) gap(0.5) alpha(80) circles(6) circlabf(%6.0fc)
```

<img src="/figures/circlebar4.png" width="100%">

```
circlebar deathspm, by(month) gap(0.5) circles(6) circtop
```

<img src="/figures/circlebar4_1.png" width="100%">

```
circlebar deathspm, by(month) gap(0.5) circles(4) ra(18000) nocirclab
```

<img src="/figures/circlebar4_2.png" width="100%">

```
circlebar deathspm, by(month) gap(0.5) palette(CET C6) nocirclab
```

<img src="/figures/circlebar5.png" width="100%">

```
circlebar deathspm, by(month) gap(2) palette(CET C6) rotatelab
```

<img src="/figures/circlebar6.png" width="100%">

```
circlebar deathspm, by(month) stack(continent) gap(2) palette(CET C6) rotatelab
```

<img src="/figures/circlebar7.png" width="100%">

```
circlebar deathspm, by(month) stack(continent) gap(1.5) radmin(5) palette(CET C6, n(6)) rotatelab lc(black) circc(gs13) ra(20000) ///
text(0 0 "Global COVID-19" "{bf:deaths per million}" "in 2021" "(by continent)",  size(2.5)) note("Source: Our World in Data", size(2))
```

<img src="/figures/circlebar7_1.png" width="100%">

```
circlebar deathspm, by(month) stack(continent) palette(tab Color Blind, n(6)) gap(0.5) radmin(4) radmax(10) ra(18000) ///
text(0 0 "Global COVID-19" "{bf:deaths per million}" "in 2021" "(by continent)",  size(2.5)) ///
note("Source: Our World in Data", size(2)) circ(5) circc(gs13) labgap(8) rotatelab labs(2.4) circlabf(%6.0fc)
```

<img src="/figures/circlebar8.png" width="100%">


### cfill options (v1.3)

```
circlebar deathspm, by(month) cfill(white) lc(black) clc(black) lw(0.1) clw(0.1)   //  name(m1, replace) 
```

<img src="/figures/circlebar9.png" width="100%">


### fix to messy arcs with very few categories (v1.3)

This updates fully fixes the issue with previous version where very few categories were resulting in distorted outputs.

```
use "https://github.com/asjadnaqvi/stata-circlebar/blob/main/data/demo_r_pjangrp3_clean?raw=true", clear

drop year
keep NUTS_ID y_TOT

drop if y_TOT==0

keep if length(NUTS_ID)==5

gen NUTS2 = substr(NUTS_ID, 1, 4)
gen NUTS1 = substr(NUTS_ID, 1, 3)
gen NUTS0 = substr(NUTS_ID, 1, 2)
ren NUTS_ID NUTS3

```


```
circlebar y_TOT if NUTS0=="IT", by(NUTS1) alpha(80)
```

<img src="/figures/circlebar10.png" width="100%">


```
circlebar y_TOT if NUTS0=="AT", by(NUTS1) alpha(80)
```

<img src="/figures/circlebar11.png" width="100%">

### unbalanced stacks (v1.3)

Another major feature request was to allow plotting stacks that are unique to each `by()` category. This has now been added:

```
circlebar y_TOT if NUTS0=="AT", by(NUTS1) stack(NUTS2) 
```

<img src="/figures/circlebar12.png" width="100%">

```
circlebar y_TOT if NUTS0=="IT", radmin(0) gap(0) by(NUTS1) stack(NUTS2)  
```

<img src="/figures/circlebar13.png" width="100%">



## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-circlebar/issues) to report errors, feature enhancements, and/or other requests. 


## Change log

**v1.31 (02 Feb 2024)**
- Fixed the label bug which was off by one slice.
- Minor cleanups.

**v1.3 (22 Jan 2024)**
- Complete rework of the base engine for drawing arcs. The program is now very stable and faster.
- Several new options added to control the circle fill including assigning border colors and line widths.
- Clean up of redundant code.

**v1.21 (25 Sep 2023)**
- Fixed a bug where `circtop` was resulting in wrong legend keys (reported by sktanamas).
- Added `saving()` and `graphregion()` options.

**v1.2 (23 Mar 2023)**
- Fixed a major bug where the legend names were reversed (reported by Christina Lin).
- Other minor code improvements.

**v1.1 (26 Feb 2023)**
- Start slice defaults to the 12 o' clock position.
- Option `rotate()` added to rotate the graph. Plus values are clockwise rotation.
- Option `labcolor()` added.
- Option `cfill()` added to change the color of the fill circle. This is useful if other backgrounds are used.

**v1.01 (06 Dec 2022)**
- Fixed several minor bugs, e.g. value labels of `stack()` variable were not passing correctly (reported by Asal Pilehvari).

**v1.0 (20 Nov 2022)**
- Public release. Currently in beta.







