*! circlebar v1.3 (22 Jan 2024)
*! Asjad Naqvi (asjadnaqvi@gmail.com)


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
 
	syntax varlist(min=1 max=1 numeric) [if] [in], by(varname) 													  ///
		[ stack(varname) radmin(real 4) radmax(real 10) gap(real 0) alpha(real 100)								] ///
		[ NOLABels ROTATELABel SHOWVALues LColor(string) LWidth(string) palette(string) NOLEGend	    		] ///
		[ NOCIRCles CIRCles(real 5) RAnge(numlist min=1 max=1) CIRCColor(string) CIRCWidth(string) CIRCTop		] ///
		[ NOCIRCLABels CIRCLABFormat(string) CIRCLABSize(string) CIRCLABColor(string)  		]   ///
		[ LABGap(real 5) LABSize(string) 					]	///
		[ title(passthru) subtitle(passthru) note(passthru)	]	///
		[ scheme(passthru) name(passthru) text(passthru) saving(passthru) graphregion(passthru) 	]   ///
		[ LABColor(string) ROtate(real 0) ] ///   // v1.1 options
		[ CFill(string) CLColor(string) CLWidth(string)	points(real 500) ]			// v1.3 options
		
		
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

	if "`radmin'" == "0" local radmin 0.01 // to avoid irregular outputs

	cap findfile carryforward.ado
	if _rc != 0 {
		qui ssc install carryforward, replace
	}	
	
	capture findfile labmask.ado
	if _rc != 0 {
		qui ssc install labutil, replace
	}	
	
	marksample touse, strok
	
qui {	
preserve	

	
	keep if `touse'
	keep `varlist' `by' `stack'  
	
	if "`stack'" != "" {
		fillin `by' `stack' // tiangularize
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
		local by by2 
	}			

	
	

	// preserve the labels of the by variable
	levelsof `by', local(idlabels)      // store the id levels
 
	foreach x of local idlabels {       
		local idlab_`x' : label `by' `x'  
	}	
	

	collapse (sum) `varlist', by(`by' `stack')
	
					
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
	

	
	*** rescale radius to (a,b) = ((b - a)(x - xmin)/(xmax - xmin)) + a	
	replace radius = ((`radmax' - `radmin') * (radius - 0) / (1 - 0)) + `radmin'
	
	gen double theta = (1 / (_N / lvls)) * 2 * -_pi  // equally divide the pies	
	*gen temp2 = angle * 180 / _pi  // for recovering the full angle
	
	// default angle is automatically calculated to start at 12 in a clockwise direction

	bysort `stack' (`by'): gen double angle = sum(theta) // - theta  + (0.5 * _pi) + (-`rotate' * _pi / 180)  

	drop theta
	
	gen double x =  radius * cos(angle) 
	gen double y =  radius * sin(angle) 		
	

	local items = _N
	
	sum `by', meanonly
	local maxval = r(max) + 1
	

	expand 2 if `by'==1 

	replace `by' = `maxval' if _n > `items'	
	sort `stack' `by'
	
	gen dummy = `varlist' == 0
	
	
	
	drop `varlist' stackvar

	
	
	gen id = 1
	reshape wide x y radius angle dummy, i(id `stack') j(`by')				

	
	
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
		
		// di "`i'"
		
		local start = `lastobs' + 1
		*local half  = `start'   + 44	
		local end   = `start'   + 96
		
		replace `stack' = `i' in `start'/`end'
		*replace half    =  1  in `start'/`half'
		
		local lastobs = `end'
		
	}

	*replace half = 2 if half==.

	
	
	// extend the idenfiers
	order `stack' serial 

	sort `stack' serial
	carryforward radius* dummy*, replace	
	

	// generate the counters
	cap drop counter
	gen counter = mod(_n, 100)
	recode counter (0 = 100)
	
		
	levelsof stack2, local(lvls)
	
	local ro = (`gap' / 2) * _pi / 180 
	local start = 0 - `ro'

	forval i = 1/`=scalar(obs)' {  // 
	
		gen double angle`i'_new = .  // check 
		gen double 	   x`i'_new = .  // check 
		gen double 	   y`i'_new = .	 // check 
		
		// arc start and end angles		
			
			summ angle`i', meanonly
			local end = r(max) + `ro'
	
			local cuts = (`end' - `start') / 99
	
			replace angle`i'_new =  `start' + `cuts' * (counter - 2) if x1!=0
			replace x`i'_new	 = radius`i' * cos(angle`i'_new)
			replace y`i'_new	 = radius`i' * sin(angle`i'_new)			
			
			local start = `end' - 2 * `ro'
	}	
	
		
		
		
	////////////////////////
	// replace and rotate //
	////////////////////////
	
		forval i = 1/`=scalar(obs)' {  // 
			replace x`i' = x`i'_new * cos(`rotate' * _pi / 180) - y`i'_new * sin(`rotate' * _pi / 180) if !missing(x`i'_new)
			replace y`i' = x`i'_new * sin(`rotate' * _pi / 180) + y`i'_new * cos(`rotate' * _pi / 180) if !missing(y`i'_new)
		}
	
	drop *new
	
	**********************	
	// add pie labels	//
	**********************
	
	cap drop xlab* ylab*
	forval x = 1/`=scalar(obs)' {
	 
		local labmax =  `radmax' * (1 + `labgap' / 100) //  push out the labels 
		local y = `x' + 1 
	  
		gen double xlab`x' =  `labmax' * cos((angle`x' + angle`y') /2) in 1
		gen double ylab`x' =  `labmax' * sin((angle`x' + angle`y') /2) in 1 
		
		gen double  ang`x' =  .
		replace ang`x' = (angle`x' + angle`y') /2 * (180 / _pi) + 180 in 1 if xlab`x' <= 0
		replace ang`x' = (angle`x' + angle`y') /2 * (180 / _pi)       in 1 if xlab`x' > 0
		
		replace ang`x' = ang`x' - 360 if ang`x' > 360
	  
	  }

	  replace ylab`=scalar(obs)' = ylab`=scalar(obs)' * -1
	  replace xlab`=scalar(obs)' = xlab`=scalar(obs)' * -1	
		
	 cap drop lab*
   
		forval i = 1/`=scalar(obs)' {
			
			if "`idlab_`i''" != "" {
				
				gen lab`i' = "`idlab_`i''" in 1	
				
			}
			else {
				gen lab`i' = `i' in 1
			}
			
		}	
		
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
	
	
	
	/////////////////
	// pie labels  //
	/////////////////
	
	local labs
	
	if "`labsize'" == "" local labsize 2
	
	if "`nolabel'" == "" {
		forval i = 1/`=scalar(obs)' {

			local j = `i' + 1	
			if "`rotatelabel'" != "" {
				summ ang`i', meanonly
				local angle = r(mean) 
			}
		 
			local labs `labs' (scatter ylab`i' xlab`i', mc(none) mlabel(lab`i') mlabpos(0) mlabcolor(`labcolor') mlabangle(`angle')  mlabsize(`labsize'))  ///  // 
		  
		} 
	}
	
	/////////////////
	//   circles   //
	/////////////////
	

	local rings
	
	if "`nocircle'" == "" {	
	
		if "`circcolor'" == "" local circcolor gs10
		if "`circwidth'" == "" local circwidth 0.1
	
	// local sides = cond("`polygon'" == "",  300, `items')   // deal with later
	
	
	local gap = (`radmax' - `radmin') / (`circles' - 1)
	
		
	if `gap' > _N {
		local newobs = `gap' + 1
		set obs `newobs'
	}
	
	
	forval x = `radmin'(`gap')`radmax' {	
		local rings `rings' (function sqrt(`x'^2 - x^2), lc(`circcolor') lw(`circwidth') lp(solid) range(-`x' `x') n(`points')) || (function -sqrt(`x'^2 - x^2), lc(`circcolor') lw(`circwidth') lp(solid) range(-`x' `x')  n(`points')) ||

		}		
	
	}
	

	if "`circtop'" != "" {
		local rings2 `rings'
		local rings
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
	
	
	if "`nolegend'" == "" & `ovrclr' == 0 {
	
		local j = 0
	
		forval i = 1/`=scalar(lvls)' {
		
		local rev = `=scalar(lvls)' - `i' + 1
		
		local t : label `stack' `rev' 
		
		
		local shift = 0  // legend shift
		if "`circtop'" == "" local shift = (`circles' * 2)	
				
		local k = `i' + ((`=scalar(obs)' - 1) * `j' ) + `shift'
		
			
		local entries `" `entries' `k'  "`t'"  "'
		
		local j = `j' + 1
		
		}
	
		local rows = floor(lvls/5) + 1 
		
		local legend legend(order("`entries'") pos(6) size(2.5) row(`rows')) 
	
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
		local palette tableau
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
			
			if `ovrclr' == 0 {
				local items = lvls
				local clr `rev'
			}
			else {
				local items = obs
				local clr `i'
			}
			
			colorpalette `palette', nograph n(`items') `poptions' 
				
			local areagraph`j' `areagraph`j'' (area y`i' x`i' if `stack'==`rev', nodropbase fi(100) fc("`r(p`clr')'%`alpha'") lc(`lcolor') lw(`lwidth')) ||
			
			
			local k = `k' + 1 // use k for purely random assignments.
		}		
	
	local areagraph `areagraph' `areagraph`j''   // collect in one local
	}
		
	
	// circle fill
	
	if "`cfill'"  	== "" local cfill white
	if "`clcolor'"  == "" local clcolor white
	if "`clwidth'"  == "" local clwidth 0.2
	
	// final graph
		
    twoway	///
		`rings'	///
		`areagraph' ///
		`rings2'	///	
			(function   sqrt(`radmin'^2 - (x)^2), recast(area) fc(`cfill') fi(100) lw(0.3) lc(`cfill') range(-`radmin' `radmin'))   /// fill top
			(function  -sqrt(`radmin'^2 - (x)^2), recast(area) fc(`cfill') fi(100) lw(0.3) lc(`cfill') range(-`radmin' `radmin'))   /// fill bot
			(function   sqrt(`radmin'^2 - (x)^2), lw(`clwidth') lc(`clcolor') range(-`radmin' `radmin'))   ///	lc top
			(function  -sqrt(`radmin'^2 - (x)^2), lw(`clwidth') lc(`clcolor') range(-`radmin' `radmin'))   ///	lc bot
			`circlabs'  ///		
			`labs'		///							
				, ///
						xsize(1) ysize(1) aspect(1)  /// 
						xscale(off) yscale(off) ///
						xlabel(-`radmax' `radmax', nogrid) ///
						ylabel(-`radmax' `radmax', nogrid) ///		
						`legend' `title' `note' `subtitle' `text' `scheme' `name' `saving'
						
*/
restore			
}



end



*********************************
******** END OF PROGRAM *********
*********************************


