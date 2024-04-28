{smcl}
{* 28Apr2024}{...}
{hi:help polarbar/circlebar}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-circlebar":polarbar/circlebar v1.5 (GitHub)}}

{hline}

{title:circlebar}: A Stata package for polar bar graphs.

Please note that this command is also mirrored as {opt polarbar} to align it with other polar packages. 

{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:circlebar} {it:var} {ifin}, {cmd:by}({it:var1}) [ {cmd:stack}({it:var2}) ]
                {cmd:[} {cmd:radmin}({it:num}) {cmd:radmax}({it:num}) {cmdab:circ:les}({it:num}) {cmd:gap}({it:num}) {cmd:alpha}({it:num}) {cmd:palette}({it:str}) {cmdab:nolab:els} {cmdab:rotatelab:el} {cmdab:showval:ues} 
                  {cmdab:nocirc:les}  {cmdab:circt:op} {cmdab:ra:nge}({it:num}) {cmdab:nocirclab:els} {cmdab:circlabf:ormat}({it:str}) {cmdab:circlabs:ize}({it:str}) {cmdab:circlabc:olor}({it:str})
                  {cmdab:labc:olor}({it:str}) {cmdab:ro:tate}({it:num}) {cmdab:lc:olor}({it:str}) {cmdab:lw:idth}({it:str}) {cmdab:circc:olor}({it:str}) {cmdab:circw:idth}({it:str})
                  {cmdab:labg:ap}({it:num}) {cmdab:labs:ize}({it:str}) {cmdab:cf:ill}({it:str}) {cmdab:clc:olor}({it:str})  {cmdab:clw:idth}({it:str}) {cmd:points}({it:num}) 
                  {cmdab:noleg:end} {cmdab:legs:ize}({it:str}) {cmdab:legpos:ition}({it:str}) {cmd:rows}({it:num}) {cmd:half} {cmd:sort} *
                {cmd:]}

{p 4 4 2}


{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt circlebar var, by(var1)} {opt stack(var2)}}The minimum syntax requires defining a numerical {it:var} variable. The placement around the circle is determined by the {it:by(var1)} variable.
The pie slices can be stacked by the {opt stack(var2)} variable. If there is more data than is required, then the program will collapse the data using the mean value of the {opt var} by {opt var1()} and {opt var2()}.
If you want other ways of summarizing the variables, then it is highly recommended to prepare the data beforehand.{p_end}

{p2coldent : {opt range(num)}}The height of the circles can be controled by defining an upper bound using {opt range()}. This ensures that data can be made comparable across graphs.
Note that if the {opt range()} value is lower than the maximum height value in the data, the program will throw an error.{p_end}

{p2coldent : {opt radmin(num)} {opt radmax(num)}}The circles are scaled between a minimum and a maximum radius defined by {opt radmin()} and {opt radmax()} respectively. 
{opt radmin()} can be set to 0 to start from the origin. This combined with the {opt stack()} option will produce Florence Nightingale's Coxcomb or roseplots.
Default values are {opt radmin(4)} and {opt radmax(10)}.{p_end}

{p2coldent : {opt half}}The the polar bar graph in a semi circle. This option is still beta and might contain bugs.{p_end}

{p2coldent : {opt sort}}Numerical sort the polar graphs. This option is still beta and might contain bugs.{p_end}

{p2coldent : {opt circ:les(num)}}The number of rings to plot between the minimum and maximum circles. Default value is {it:5} for five circles.{p_end}

{p2coldent : {opt ro:tate(num)}}Rotate the whole graph by {it:num} degrees. For example, {opt ro(30)} is a 30 degree clockwise rotation. Default is {opt ro(0)}.{p_end}

{p2coldent : {opt gap(num)}}A gap in degrees between the pie slices. For example, {opt gap(2)} will space the slices by 2 degrees. Default is {opt gap(0)}.{p_end}

{p2coldent : {opt alpha(num)}}The transparency control of the arc area fills. The value ranges from 0-100, where 0 is no fill and 100 is fully filled.
Default value is {opt alpha(100)}. Use this carefully with the {it:stack()} option as it might cause weird color blendings.{p_end}

{p2coldent : {opt palette(str)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt circt:op}}Draw reference circles on top.{p_end}

{p2coldent : {opt nocirc:les}}Hide the reference circles.{p_end}

{p2coldent : {opt nolab:els}}Hide the slice labels.{p_end}

{p2coldent : {opt rotatelab:els}}Rotate the slice labels to orient themselves with the angle of the slices.{p_end}

{p2coldent : {opt labg:ap(num)}}Gap of the slice labels. Default value is {opt labg(5)} for 5% of the radius of the largest slice.{p_end}

{p2coldent : {opt labs:ize(str)}}Size of the slice labels. Default value is {opt labs(1.6)}.{p_end}

{p2coldent : {opt labc:olor(str)}}Color of the slice labels. Default value is {opt labc(black)}.{p_end}

{p2coldent : {opt nocirclab:els}}Hide the labels of the reference circles.{p_end}

{p2coldent : {opt circlabf:ormat}}Format the labels of the reference circles. Default is {opt circlabf(%5.0f)}.{p_end}

{p2coldent : {opt circlabs:ize}}Size of the labels of the reference circles. Default is {opt circlabs(1.8)}.{p_end}

{p2coldent : {opt circlabc:olor}}Color of the labels of the reference circles. Default is {opt circlabc(gs8)}.{p_end}

{p2coldent : {opt lc:olor(str)}}Color of the slice outlines. Default value is {opt lc(white)}.{p_end}

{p2coldent : {opt lw:idth(str)}}Line width of slice outlines. Default value is {opt lw(0.1)}.{p_end}

{p2coldent : {opt circc:olor(str)}}Color of the circles. Default value is {opt circc(gs10)}.{p_end}

{p2coldent : {opt circlw:idth(str)}}Line width of the circles. Default value is {opt circlw(0.1)}.{p_end}

{p2coldent : {opt cf:ill(str)}}The fill color of the center circle. Default value is {opt cfill(white)}.
This option is especially useful if a non-white background is used.{p_end}

{p2coldent : {opt clc:olor(str)}}Line color of the center circle line. Default is {opt clc(white)}.{p_end}

{p2coldent : {opt clw:idth(str)}}Line with of the center circle line. Default is {opt clw(0.2)}.{p_end}

{p2coldent : {opt points(num)}}Advanced option for setting the number of points to generate the circles. Default is {opt points(500)} which works fine.{p_end} 

{p2coldent : {opt noleg:end}}Turn off the legend.{p_end}

{p2coldent : {opt rows(num)}}Number of legend rows. Default is {opt rows(3)}.{p_end}

{p2coldent : {opt legs:ize(str)}}Size of legend entries. Default is {opt legs(2.2)}.{p_end}

{p2coldent : {opt legpos:ition(str)}}Position of legend. Default is {opt legpos(6)} for 6 o' clock.{p_end}

{p2coldent : {opt *}}All other standard twoway options unless overwritten by the program.{p_end}


{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018, 2022) is required:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}

Even if you have these installed, it is highly recommended to update the dependencies:
{stata ado update, update}

{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-circlebar":GitHub}.


{hline}


{title:Package details}

Version      : {bf:polarbar} {bf:circlebar} v1.5
This release : 28 Apr 2024
First release: 18 Nov 2022
Repository   : {browse "https://github.com/asjadnaqvi/stata-circlebar":GitHub}
Keywords     : Stata, circle bar graphs
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}


{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-joyplot/issues":GitHub} by opening a new issue.

{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43. 

{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb joyplot}, 
	{helpb marimekko}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb streamplot}, {helpb sunburst}, {helpb treecluster}, {helpb treemap}, {helpb waffle}


