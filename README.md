
![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-circlebar) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-circlebar) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-circlebar) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-circlebar) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-circlebar)


---

[Installation](#Installation) | [Syntax](#Syntax) | [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---

# circlebar v1.1

This package allows us to draw circular bar graphs in Stata.


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC (**v1.1**):

```
ssc install circlebar, replace
```

GitHub (**v1.1**):

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

The syntax for **v1.1** is as follows:

```applescript
circlebar var [if] [in], by(var) [ stack(var) ]
                [ radmin(num) radmax(num) circles(num) gap(num) alpha(num) palette(str)
                  nolabels rotatelabel showvalues nocircles  circtop nolegend range(num)
                  nocirclabels circlabformat(str) circlabsize(str) circlabcolor(str)
                  cfill(str) labcolor(str) rotate(num)
                  lcolor(str) lwidth(str) circcolor(str) circwidth(str) labgap(num) labsize(str)
                  title(str) subtitle(str) note(str) name(str)                              
                ]
```

See the help file `help circlebar` for details.

The most basic use is as follows:

```
circlebar values, by(var1) stack(var2)
```

where `var1` and `var2` are the string source and destination variables respectively against which the `values` are plotted.



## Examples

Get the example data from GitHub:

```
use "https://github.com/asjadnaqvi/stata-circlebar/blob/main/data/cbardata.dta?raw=true", clear
```

Let's test the `circlebar` command:

```
circlebar deathspm, by(month) 
```

<img src="/figures/circlebar1.png" height="600">

```
circlebar deathspm, by(month) nocirclab
```

<img src="/figures/circlebar1_1.png" height="600">


```
circlebar deathspm, by(month) radmin(0)
```

<img src="/figures/circlebar2.png" height="600">

```
circlebar deathspm, by(month) gap(0.5)
```

<img src="/figures/circlebar3.png" height="600">

```
circlebar deathspm, by(month) gap(0.5) alpha(80) circles(6) circlabf(%6.0fc)
```

<img src="/figures/circlebar4.png" height="600">

```
circlebar deathspm, by(month) gap(0.5) circles(6) circtop
```

<img src="/figures/circlebar4_1.png" height="600">

```
circlebar deathspm, by(month) gap(0.5) circles(4) ra(18000) nocirclab
```

<img src="/figures/circlebar4_2.png" height="600">

```
circlebar deathspm, by(month) gap(0.5) palette(CET C6) nocirclab
```

<img src="/figures/circlebar5.png" height="600">

```
circlebar deathspm, by(month) gap(2) palette(CET C6) rotatelab
```

<img src="/figures/circlebar6.png" height="600">

```
circlebar deathspm, by(month) stack(continent) gap(2) palette(CET C6) rotatelab
```

<img src="/figures/circlebar7.png" height="600">

```
circlebar deathspm, by(month) stack(continent) gap(1.5) radmin(5) palette(CET C6, n(6)) rotatelab lc(black) circc(gs13) ra(20000) ///
text(0 0 "Global COVID-19" "{bf:deaths per million}" "in 2021" "(by continent)",  size(2.5)) note("Source: Our World in Data", size(2))
```

<img src="/figures/circlebar7_1.png" height="600">

```
circlebar deathspm, by(month) stack(continent) palette(tab Color Blind, n(6)) gap(0.5) radmin(4) radmax(10) ra(18000) ///
text(0 0 "Global COVID-19" "{bf:deaths per million}" "in 2021" "(by continent)",  size(2.5)) ///
note("Source: Our World in Data", size(2)) circ(5) circc(gs13) labgap(8) rotatelab labs(2.4) circlabf(%6.0fc)
```

<img src="/figures/circlebar8.png" height="600">


## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-circlebar/issues) to report errors, feature enhancements, and/or other requests. 


## Change log

**v1.1 (26 Feb 2023)**
- Start slice defaults to the 12 o' clock position.
- Option `rotate()` added to rotate the graph. Plus values are clockwise rotation.
- Option `labcolor()` added.
- Option `cfill()` added to change the color of the fill circle. This is useful if other backgrounds are used.

**v1.01 (06 Dec 2022)**
- Fixed several minor bugs, e.g. value labels of `stack()` variable were not passing correctly (reported by Asal Pilehvari).

**v1.0 (20 Nov 2022)**
- Public release. Currently in beta.







