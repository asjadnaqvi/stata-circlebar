*! circlebar/polarbar v1.6 (05 Oct 2024)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

* v1.6  (05 Oct 2024): added showtotal, stat(), format(), labnear, labvar(), colorvar() rline(), rclinec(), rlinep(), circlabpos()	
* v1.5	(28 Apr 2024): Better passthru options. Many bug fixes. Added half. Added sort.
* v1.4  (03 Feb 2024): better legend options added. other code cleanup. 
* v1.31	(02 Feb 2024): labels need to be rotated by one. Added ability to sort by height
* v1.3	(22 Jan 2024): rewrite of base routines, major code clean, support for unbalanced panels
* v1.21 (25 Sep 2023): Fixed a bug where circtop was resulting in wrong legend keys.  saving(), graphregion() added.
* v1.2  (23 Mar 2023): fixed a bug where legend names were reversed. Improved other parts of the code.
* v1.1  (26 Feb 2023): added: cfill(), labcolor(), rotate(). label angle fixed. Various bug fixes.
* v1.01 (06 Dec 2022): Minor fixes
* v1.0  (20 Nov 2022): First release

**********************************

* A simpler version of the code description is available here: 
* https://medium.com/the-stata-guide/stata-graphs-circular-bar-graphs-ii-8ae960ec49d6

cap program drop circlebar


program circlebar, sortpreserve

version 15
 
	syntax varlist(min=1 max=1 numeric) [if] [in] [aw fw pw iw/], by(varname) 									  ///
		[ stack(varname) radmin(real 4) radmax(real 10) gap(real 0) alpha(real 100)								] ///
		[ NOLABel ROTATELABel SHOWVALues LColor(string) LWidth(string) palette(string) NOLEGend	    			] ///
		[ NOCIRCles CIRCles(real 5) RAnge(numlist min=1 max=1) CIRCColor(string) CIRCWidth(string) CIRCTop		] ///
		[ NOCIRCLABels CIRCLABFormat(string) CIRCLABSize(string) CIRCLABColor(string)  							] ///
		[ LABGap(real 10) LABSize(string) legend(passthru)														] ///
		[ LABColor(string) ROtate(real 0) 																		] ///   // v1.1 options
		[ CFill(string) CLColor(string) CLWidth(string)	points(numlist max=1 >100) 								] ///	// v1.3 options
		[ rows(real 3) LEGSize(string) LEGPOSition(string) half sort 	   										] ///   // v1.4 options
		[ * aspect(real 1) xsize(real 1) ysize(real 1) 															] ///	// v1.5 options
		[ SHOWTOTal stat(string) format(string) labnear LABVARiable(varlist max=1 string) COLORVARiable(varlist max=1 numeric) ] /// // v1.6
		[ rline(numlist max=1) RLINEColor(string) RLINEWidth(string) RLINEPattern(string)   ] 										 // v1.6
		
	// check dependencies
	capture findfile colorpalette.ado
	if _rc != 0 {
		display as error "The {bf:palettes} package is missing. Install the {stata ssc install palettes, replace:palettes} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}
	
	
	if `radmin' >= `radmax' {
		di as error  "{bf:radmin()} >= {bf:radmax()}. "	
		exit 
	}

	if "`stat'" != "" & !inlist("`stat'", "mean", "sum") {
		display as error "Valid options are {bf:stat(mean)} or {bf:stat(sum) [default]}."
		exit
	}	
	
	
	if "`radmin'" == "0" local radmin 0.01 // to avoid irregular outputs...

	cap findfile carryforward.ado
	if _rc != 0 quietly ssc install carryforward, replace
	
	
	capture findfile labmask.ado
	if _rc != 0 quietly ssc install labutil, replace
	
	marksample touse, strok
	
quietly {	
preserve	
	
	keep if `touse'
	drop if missing(`varlist')
	
	keep `varlist' `by' `stack' `labvariable' `colorvariable' `exp'
	
	
	if "`stack'" != "" {
		fillin `by' `stack'  // tiangularize
		recode `varlist' (.=0)
	}
	
	// local options
	
	local ovrclr = 0
	
	if "`stack'" == "" {
		gen ov = 1
		local stack ov
		local ovrclr = 1
	}
	
	
	// finetune the stack variable
	
	cap confirm numeric var `stack'

	if _rc!=0 {  // if string
		tempvar stack2
		encode `stack', gen(stack2)
		local stack stack2 
	}
	else {
		tempvar tempst stack2
		egen   stack2 = group(`stack')
		
		if "`: value label `stack''" != "" {
			decode `stack', gen(`tempst')		
			labmask stack2, val(`tempst')
		}
		local stack stack2 
	}
	
			
	cap confirm numeric var `by'

	if _rc!=0 {  // if string
		tempvar by2
		encode `by', gen(by2)
		local by by2 
	}
	else {
		tempvar tempov by2
		egen   by2 = group(`by')
		
		if "`: value label `by''" != "" {
			decode `by', gen(`tempov')		
			labmask by2, val(`tempov')
		}
		else {
			labmask by2, val(`by')
		}
		
		local by by2 
	}			

	
	if "`stat'" 	== "" local stat sum
	if "`weight'" 	!= "" local myweight  [`weight' = `exp']	

	
	if "`labvariable'" != "" 	local keeplabvar (first) `labvariable'
	
	if "`colorvariable'" != ""  {
		egen _clrgrp = group(`colorvariable')
		drop `colorvariable'
		local colorvariable _clrgrp
		
		local keepclrvar (first) `colorvariable'
	}
	
	collapse (`stat') `varlist' `keeplabvar' `keepclrvar' `myweight' , by(`by' `stack')
	
	
	if "`sort'" != "" {		// optimize this part
		bysort `by': egen _count = sum(`varlist')
		gsort -_count `by'
		egen _tag = tag(_count `by')
		gen _rank = sum(_tag)
		decode by2, gen(_temp2)
		labmask _rank, val(_temp2)
		drop _count _tag _temp2 
		drop by2
		local by _rank
		
	}		

	
	// preserve the labels and values
	levelsof `by', local(idlabels)   
 
	foreach x of local idlabels {       
		local idlab_`x' : label `by' `x'  
		
		summ `varlist' if `by'==`x', meanonly
		local idval_`x' = r(sum)
	}	
		
	
	bysort `by' (`stack'): gen double stackvar = sum(`varlist')				


	summ stackvar, meanonly
	local maxval = r(max) // the maximum value of the height
				
	levelsof `by'
	scalar obs = `r(r)'

	levelsof `stack'
	scalar lvls = `r(r)'	
	
	if "`range'" != "" {
		local rhi `range'		
		
		summ stackvar, meanonly
		
		if `r(max)' > `rhi' {
			noi di as err "The {bf:range} upper bound of `rhi' is lower than the maximum value `r(max)' in the data."
			exit
		}
	}	
	else {
		summ stackvar, meanonly
		local rhi = r(max)
	}
	
	
	gen double radius = (stackvar / `rhi')   
	
	local 2pi = 2

	if "`half'"!= "" local 2pi = -1
	
	*** rescale radius to (a,b) = ((b - a)(x - xmin)/(xmax - xmin)) + a	
	replace radius = ((`radmax' - `radmin') * (radius - 0) / (1 - 0)) + `radmin'
	
	gen double theta = (1 / (_N / lvls)) * `2pi' * -_pi  // equally divide the pies. full angle = 	angle * 180 / _pi

	bysort `stack' (`by'): gen double angle = sum(theta) // - theta  + (0.5 * _pi) + (-`rotate' * _pi / 180)  

	gen double x =  radius * cos(angle) 
	gen double y =  radius * sin(angle) 		
	
	drop theta
	local items = _N
	
	sum `by', meanonly
	local maxval = r(max) + 1
	
	expand 2 if `by'==1 

	replace `by' = `maxval' if _n > `items'	
	sort `stack' `by'
	
	gen dummy = `varlist' == 0
	drop `varlist' stackvar

	gen id = 1
	reshape wide x y radius angle dummy `labvariable' `colorvariable', i(id `stack' ) j(`by')				


	expand 3		
	sort `stack'
	bysort `stack' : gen serial = _n
	order `stack' serial		
		

	forval i = 1/`=scalar(obs)' {   
		
		// add the intercept dummy for the pie
		replace x`i' = 0 if serial==1  
		replace y`i' = 0 if serial==1
		
		// pick the ending point from the next arc
		local j = `i' + 1
		replace x`i' = x`j' * radius`i' / radius`j' if serial==3
		replace y`i' = y`j' * radius`i' / radius`j' if serial==3
		
		recode x`i' (.=0) if serial==3  // for division with zero
		recode y`i' (.=0) if serial==3
		
	}			
		
	
	
	****** get the arc right

	gen marker0 = 0 in 1	// identify the origin. important for sorting later

	local lastobs = _N

	
	// expand the rows = 100 * categories
		
	levelsof `stack'
	local obsnew = _N + 97 * lvls
	set obs  `obsnew'		// points for the arc. more points = smoother arc but slower


	forval i = 1 / `=scalar(lvls)' {
		local start 	= `lastobs' + 1
		local end   	= `start'   + 96
		replace `stack' = `i' in `start'/`end'
		
		local lastobs 	= `end'
		
	}
	
	
	// extend the idenfiers
	order `stack' serial 

	sort `stack' serial
	carryforward radius* dummy*, replace	
	

	// generate the counters
	cap drop counter
	gen counter = mod(_n, 100)
	recode counter (0 = 100)
	
		
	levelsof stack2, local(lvls)
	
	local ro 	= (`gap' / 2) * _pi / 180 
	local start = 0 - `ro'

	forval i = 1/`=scalar(obs)' {  // 
	
		gen double angle`i'_new = .  
		gen double 	   x`i'_new = .  
		gen double 	   y`i'_new = .	 
		
		// arc start and end angles		
			
		summ angle`i', meanonly
		local end = r(max) + `ro'
		local cuts = (`end' - `start') / 99
	
		replace angle`i'_new =  `start' + `cuts' * (counter - 2) if x1!=0
		replace x`i'_new	 = radius`i' * cos(angle`i'_new)
		replace y`i'_new	 = radius`i' * sin(angle`i'_new)			
			
		local start = `end' - 2 * `ro'
	}	
	

	// replace and rotate 
	
		forval i = 1/`=scalar(obs)' {  // 
			replace x`i' = x`i'_new * cos(`rotate' * _pi / 180) - y`i'_new * sin(`rotate' * _pi / 180) if !missing(x`i'_new)
			replace y`i' = x`i'_new * sin(`rotate' * _pi / 180) + y`i'_new * cos(`rotate' * _pi / 180) if !missing(y`i'_new)
		}
	

	drop *new
	
	if "`format'" == "" local format "%8.1f"
	

	**********************	
	// add pie labels	//
	**********************
		
	gen double _x = .
	gen double _y = .
	gen double _angle = .
	gen double _value = .
	gen double _radius = .
	gen _color = .
	
	gen _lab = ""
	
	gen angle0 = 0 in 1
	
	forval x = 1/`=scalar(obs)' {
	 
		local y = `x' - 1
	 
		replace _radius = radius`x'[1]  in `x'
		
		local mygap = `radmax' * `labgap' / 100 // fix the gaps
			 
		if "`labnear'" != "" {
			summ radius`x', meanonly
			replace _radius =  `r(max)' + `mygap' in `x'
		}
		else {
			replace _radius =  `radmax' + `mygap' in `x' 
		}
	  
		replace _x 		=  _radius * cos((angle`y'[1] + angle`x'[1]) /2) in `x'
		replace _y 		=  _radius * sin((angle`y'[1] + angle`x'[1]) /2) in `x' 

		replace _value 	= `idval_`x'' in `x'

		replace _angle 	= (angle`y'[1] + angle`x'[1]) / 2 * (180 / _pi) + 180 in `x' if _x <= 0
		replace _angle 	= (angle`y'[1] + angle`x'[1]) / 2 * (180 / _pi)       in `x' if _x > 0
		
		if "`colorvariable'" != "" {
			replace _color = `colorvariable'`x'[1] in `x'
		}
		else {
			replace _color = `x' in `x'
		}
		
		
		if "`labvariable'" != "" {
				replace _lab = `labvariable'`x'[1] in `x'
		}
		else {
			if "`showtotal'" != "" {
				replace _lab = "`idlab_`x''" + " (" + string(_value, "`format'") + ")" in `x'
			}
			else {
				replace _lab = "`idlab_`x''" in `x'
			}
		}
	}
	  
	drop angle0

	
	
	
	///////////////////////
	//   circle labels   //
	///////////////////////			
	
	local gap = (`radmax' - `radmin') / (`circles' - 1)
	
	if "`circlabformat'" == "" local circlabformat %5.0f
	if "`circlabsize'"   == "" local circlabsize  = 1.6
	if "`circlabcolor'"  == "" local circlabcolor gs8
	if "`labcolor'"  	 == "" local labcolor black
	
	
	local gap2 = (`rhi' - 0) / (`circles' - 1)
	
	gen xvar = .
	gen yvar = .
	gen xlab = ""

	
	local i = 1

	forval x = `radmin'(`gap')`radmax' {
		replace xlab = string(0 + ((`i' - 1) * `gap2'), "`circlabformat'")  in `i' 
		replace xvar =  `x'  in `i'	
		replace yvar =  0  in `i'	
	   
		local i = `i' + 1 
	}	
		

			
	*****************
	***    draw   ***
	*****************
	
	///////////////////////
	//   ring line		 //
	///////////////////////
	
	if "`rline'" != "" {	
		
		if "`rlinecolor'" == "" local rlinecolor black
		if "`rlinewidth'" == "" local rlinewidth 0.15
		if "`rlinepattern'" == "" local rlinepattern solid
		
		local rline = ((`radmax' - `radmin') * `rline' / `rhi') + `radmin'		

		
			local ringline 				(function  sqrt(`rline'^2 - x^2), lc(`rlinecolor') lw(`rlinewidth') lp(`rlinepattern') range(-`rline' `rline'))
			
		if "`half'" == "" {
			local ringline `ringline' 	(function -sqrt(`rline'^2 - x^2), lc(`rlinecolor') lw(`rlinewidth') lp(`rlinepattern') range(-`rline' `rline'))
		}		

	}		
	
	
	/////////////////
	// pie labels  //
	/////////////////
	
	local labs
	
	if "`labsize'" == "" local labsize 2
	
	if "`nolabel'" == "" {
		
		if "`rotatelabel'" != "" {
			forval i = 1/`=scalar(obs)' {
				summ _angle in `i', meanonly
				local angle = r(mean) 
				
				local labs `labs' (scatter _y _x in `i', mc(none) mlabel(_lab) mlabpos(0) mlabcolor(`labcolor') mlabangle(`angle')  mlabsize(`labsize'))  
			} 
		}
		else {
			local labs `labs' (scatter _y _x, mc(none) mlabel(_lab) mlabpos(0) mlabcolor(`labcolor') mlabsize(`labsize'))  	
		}
	}
	
	
	/////////////////
	//   circles   //
	/////////////////
	

	local rings
	
	if "`nocircles'" == "" {	
		
		if "`circcolor'" == "" local circcolor gs10
		if "`circwidth'" == "" local circwidth 0.1

		local gap = (`radmax' - `radmin') / (`circles' - 1)
		
		if `gap' > _N {
			local newobs = `gap' + 1
			set obs `newobs'
		}
		

		forval x = `radmin'(`gap')`radmax' {	
			    local rings `rings' (function  sqrt(`x'^2 - x^2), lc(`circcolor') lw(`circwidth') lp(solid) range(-`x' `x') n(`points'))
			
			if "`half'" == "" {
				local rings `rings' (function -sqrt(`x'^2 - x^2), lc(`circcolor') lw(`circwidth') lp(solid) range(-`x' `x') n(`points'))
			}		
		}
		

		if "`circtop'" != "" {
			local rings2 `rings'
			local rings
		}
	
	}
	
	

	///////////////////////
	//   circle labels   //
	///////////////////////
	
	if "`nocirclabels'" == "" {
		local circlabs (scatter yvar xvar, mc(none) mlab(xlab) mlabpos(0) mlabcolor(`circlabcolor') mlabsize(`circlabsize'))  
	}
	


	/////////////////
	//   legend    //
	/////////////////
	
	

	
	
	if "`legsize'" 		== "" local legsize 2.2
	if "`legposition'" 	== "" local legposition 6
	
	if "`nolegend'" == "" & `ovrclr' == 0 {
		local j = lvls - 1
	
		forval i = 1/`=scalar(lvls)' {
		
			local rev = lvls - `i' + 1
			local t : label `stack' `i' 
			local shift = 0  // legend shift
			if "`circtop'" == "" local shift = (`circles' * 2)	
			local k = `rev' + ((obs - 1) * `j' ) + `shift'

			local entries `" `entries' `k'  "`t'"  "'
			local --j
		}	
		
		local legend legend(order("`entries'") pos(`legposition') size(`legsize') rows(`rows') region(fcolor(none))) 
	
	}
	else {
		local legend legend(off)
	}
	
	
	/////////////////
	// main layer  //
	/////////////////
	
	
	if "`lwidth'" =="" local lwidth 0.1
	if "`lcolor'" =="" local lcolor white
	if "`palette'" == "" {
		local palette ptol rainbow
	}
	else {
		tokenize "`palette'", p(",")
		local palette  `1'
		local poptions `3'
	}
	
	
	local areagraph
	local k = 1
	
	forval j = 1/`=scalar(lvls)' {
	
	local rev = `=scalar(lvls)' - `j' + 1 // reverse the sorting. draw last show first rule.
	
		forval i = 1/`=scalar(obs)' {
			
			if `ovrclr'== 1 {
				
				summ _color, meanonly
				local items = `r(max)'
				
				summ _color in `i', meanonly
				local clr = `r(min)'
			}
			else {
				local items = lvls
				local clr `rev'
				
			}
			
			colorpalette `palette', `poptions'  n(`items')  nograph

			local areagraph `areagraph' (area y`i' x`i' if `stack'==`rev', nodropbase fi(100) fc("`r(p`clr')'%`alpha'") lc(`lcolor') lw(`lwidth')) 
			
			local ++k  
		}		

	}
	
	// circle fill
	
	if "`cfill'"  	== "" local cfill white
	if "`clcolor'"  == "" local clcolor white
	if "`clwidth'"  == "" local clwidth 0.2
	
		local fill 							(function   sqrt(`radmin'^2 - (x)^2), recast(area)  fc(`cfill') fi(100) lw(0.3) lc(`cfill') range(-`radmin' `radmin'))  //  fill top
		if "`half'"=="" local fill `fill'   (function  -sqrt(`radmin'^2 - (x)^2), recast(area)  fc(`cfill') fi(100) lw(0.3) lc(`cfill') range(-`radmin' `radmin'))  //  fill bot
		local fill `fill' 					(function   sqrt(`radmin'^2 - (x)^2), lw(`clwidth') lc(`clcolor') range(-`radmin' `radmin'))  //	lc top
		if "`half'"=="" local fill `fill'   (function  -sqrt(`radmin'^2 - (x)^2), lw(`clwidth') lc(`clcolor') range(-`radmin' `radmin'))  //	lc bot	
	
	
	local ymin = -`radmax'
	
		if "`half'"!="" {
			local aspect 0.5
			local xsize 2
			local ymin = 0
		}
		
	
	local ysize 1
	local xsize 1

	if "`half'"!="" local xsize 2


	**** final graph  
		
    twoway				///
		`rings'			///
		`areagraph' 	///
		`rings2'		///	
		`fill'			///
			`circlabs'  ///		
			`labs'		///
			`ringline'	///
				, 		///
					xsize(`xsize') ysize(`ysize') aspect(`aspect')  /// 
					xscale(off) yscale(off) ///
					xlabel(-`radmax' `radmax', nogrid) ///
					ylabel( `ymin' 	 `radmax', nogrid) ///		
					`legend' `options'
						
*/
restore			
}

end



*********************************
******** END OF PROGRAM *********
*********************************


