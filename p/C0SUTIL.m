C0SUTIL	  ; GPL - Smart Processing Utilities ;2/22/12  17:05
	;;1.0;VISTA SMART CONTAINER;;Sep 26, 2012;Build 5
	;Copyright 2012 George Lilly.  
	;
	; This program is free software: you can redistribute it and/or modify
	; it under the terms of the GNU Affero General Public License as
	; published by the Free Software Foundation, either version 3 of the
	; License, or (at your option) any later version.
	;
	; This program is distributed in the hope that it will be useful,
	; but WITHOUT ANY WARRANTY; without even the implied warranty of
	; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	; GNU Affero General Public License for more details.
	;
	; You should have received a copy of the GNU Affero General Public License
	; along with this program.  If not, see <http://www.gnu.org/licenses/>.
	;
	Q
	;
SPDATE(ZDATE)	; extrinsic which returns the Smart date format yyyy-mm-dd
	; ZDATE is a fileman format date
	N TMPDT
	S TMPDT=$$FMTE^XLFDT(ZDATE,"7D") ; ordered date
	S TMPDT=$TR(TMPDT,"/","-") ; change slashes to hyphens
	I TMPDT="" S TMPDT="UNKNOWN"
	N Z2,Z3
	S Z2=$P(TMPDT,"-",2)
	S Z3=$P(TMPDT,"-",3)
	I $L(Z2)=1 S $P(TMPDT,"-",2)="0"_Z2
	I $L(Z3)=1 S $P(TMPDT,"-",3)="0"_Z3
	Q TMPDT
	;
