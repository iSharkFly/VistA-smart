C0SPROB   ; GPL - Smart Problem Processing ;5/01/12  17:05
 ;;0.1;C0S;nopatch;noreleasedate;Build 2
 ;Copyright 2012 George Lilly.  Licensed under the terms of the GNU
 ;General Public License See attached copy of the License.
 ;
 ;This program is free software; you can redistribute it and/or modify
 ;it under the terms of the GNU General Public License as published by
 ;the Free Software Foundation; either version 2 of the License, or
 ;(at your option) any later version.
 ;
 ;This program is distributed in the hope that it will be useful,
 ;but WITHOUT ANY WARRANTY; without even the implied warranty of
 ;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ;GNU General Public License for more details.
 ;
 ;You should have received a copy of the GNU General Public License along
 ;with this program; if not, write to the Free Software Foundation, Inc.,
 ;51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 ;
 Q
 ;
 ; sample VistA NHIN problem list
 ;
G("node16rk1fgdvx276397","code")="loinc:8480-6"
G("node16rk1fgdvx276397","dcterms:title")="systolic blood pressure"
G("node16rk1fgdvx276397","rdf:type")="sp:CodedValue"
G("node16rk1fgdvx276398","rdf:type")="sp:VitalSign"
G("node16rk1fgdvx276398","unit")="mm[Hg]"
G("node16rk1fgdvx276398","value")="113.0"
G("node16rk1fgdvx276398","vitalName")="node16rk1fgdvx276397"

 ;
VITALS(GRTN,C0SARY) ; GRTN, passed by reference,
 ; is the return name of the graph created. "" if none
 ; C0SARY is passed in by reference and is the NHIN array of problems
 ;
 I $O(C0SARY("vital",""))="" D  Q  ;
 . I $D(DEBUG) W !,"No Vital Signs"
 S GRTN="" ; default to no vital signs
 N C0SGRF
 S C0SGRF="/vista/smart/"_ZPATID_"/vitals"
 I $D(DEBUG) W !,"Processing ",C0SGRF
 D DELGRAPH^C0XF2N(C0SGRF) ; delete the old graph
 D INITFARY^C0XF2N("C0XFARY") ; which triple store to use
 N FARY S FARY="C0XFARY"
 D USEFARY^C0XF2N(FARY)
 D VOCINIT^C0XUTIL
 ;
 D STARTADD^C0XF2N ; initialize to create triples
 ;
 N ZI S ZI=""
 F  S ZI=$O(C0SARY("vital",ZI)) Q:ZI=""  D  ;
 . N LRN,ZR ; ZR is the local array for building the new triples
 . S LRN=$NA(C0SARY("problem",ZI)) ; base for values in this lab result
 . ;
 . N PROBID ; unique Id for this problem
 . S PROBID=C0SGRF_"/"_$$LKY17^C0XF2N ; use a random number
 . ;
 . ; i don't like this because the same problems gets a
 . ; different ID every time it's reported. Can't trace it back to VistA
 . ; I'd rather be using id@value ie "id@value")="118"
 . ;
 . N SNOMED,ICD S ICD=$G(@LRN@("icd@value"))
 . S SNOMED=$$SNOMED(ICD) ; look up the snomed code in the map
 . I SNOMED="" S SNOMED=ICD ; if not found, return the ICD code
 . N SNOGRF S SNOGRF="snomed:"_SNOMED
 . N SNOTIT S SNOTIT=$G(@LRN@("name@value"))
 . I $D(DEBUG) D  ;
 . . W !,"Processing Problem List ",PROBID
 . . W !,"problem: ",SNOTIT
 . . W !,"code: ",SNOMED
 . ;
 . ; first do the base result graph
 . ;
 . S ZR("rdf:type")="sp:Problem"
 . S ZR("sp:belongsTo")=C0SGRF ; the subject for this patient's problems
 . ; ie /vista/smart/99912345/problems
 . ;
 . N PROBNAME S PROBNAME=$$ANONS^C0XF2N ; new node for problem name
 . S ZR("sp:problemName")=PROBNAME
 . ;
 . N STARTDT S STARTDT=$$SPDATE^C0SUTIL($G(@LRN@("entered@value")))
 . S ZR("sp:startDate")=STARTDT
 . ;
 . D ADDINN^C0XF2N(C0SGRF,PROBID,.ZR) ; addIfNotNull the triples
 . K ZR ; clean up
 . ;
 . ; create the problemName graph
 . ;
 . S ZR("rdf:type")="sp:CodedValue"
 . S ZR("sp:code")="snomed:"_SNOMED
 . S ZR("dcterms:title")=$G(@LRN@("name@value"))
 . D ADDINN^C0XF2N(C0SGRF,PROBNAME,.ZR)
 . K ZR
 . ;
 . ; create snomed graph
 . ; 
 . S ZR("rdf:type")="sp:Code"
 . S ZR("sp:system")="http://purl.bioontology.org/ontology/SNOMEDCT"
 . S ZR("dcterms:identifier")=SNOMED
 . S ZR("dcterms:title")=SNOTIT
 . D ADDINN^C0XF2N(C0SGRF,SNOGRF,.ZR)
 . K ZR
 . ;
 D BULKLOAD^C0XF2N(.C0XFDA)
 S GRTN=C0SGRF
 Q
 ;
SNOMED(ZICD) ; extrinsic which returns SNOMED code given an ICD9 code
 ; requires the mapping table installed in the triplestore
 ;
 N ZSN,ZARY,ZSUB
 S ZSUB=$$subject^C0XGET1(,ZICD) ; subject of the ICD9 code
 D objects^C0XGET1(.ZARY,ZSUB,"cg:ontology#toCode")
 S ZSN=$O(ZARY(""))
 I $D(DEBUG) W !,ZSN," ",$$object^C0XGET1(ZSUB,"rdfs:label")
 Q ZSN
 ;