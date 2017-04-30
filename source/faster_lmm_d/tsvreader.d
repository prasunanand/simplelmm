/*
   This code is part of faster_lmm_d and published under the GPLv3
   License (see LICENSE.txt)

   Copyright © 2017 Prasun Anand & Pjotr Prins
*/

module faster_lmm_d.tsvreader;

import std.csv;
import std.conv;
import std.experimental.logger;
import std.file;
import std.json;
import std.regex;
import std.string;
import std.typecons;

import faster_lmm_d.dmatrix;
import faster_lmm_d.optmatrix;

auto tsvpheno(string fn, int p_column= 0){
	trace("In tsvpheno");
	double[] y;
  string[] ynames;
  string input = cast(string)std.file.read(fn);

  string[] lines = input.split("\n");
  assert(lines[0] == "# Phenotype format version 1.0");
  lines = lines[4..$];
  foreach(line; lines){
  	if(line != ""){
  		string[] row = line.split("\t");
	  	y ~=  to!double(row[1]);// <--- slow
	  	ynames ~= to!string(row[0]);
  	}

  }
  return Tuple!(double[], string[])(y, ynames);
}// # FIXME: column not used

genoObj tsvgeno(string fn, JSONValue ctrl){

  trace("in geno function");
  string s = `{"A":0,"H":1,"B":2,"-":3}`;
  ctrl["na-strings"] = parseJSON(s);

  int[dchar] hab_mapper;

  foreach( key, value; ctrl["na-strings"].object){
    dchar a  = to!dchar(key);
    string b = to!string(value);
    int c = to!int(b);
    hab_mapper[a] = c;
  }

  double[] faster_lmm_d_mapper = [ 0.0, 0.5, 1.0, double.nan,];

  log("hab_mapper", hab_mapper);
  log("faster_lmm_d_mapper", faster_lmm_d_mapper);


  string input = cast(string)std.file.read(fn);
  string[] rows = input.split("\n");

  string[] gnames = rows[4].split("\t");
  gnames = gnames[1..$];

  double[] gs2;

  int rowCount = cast(int)rows.length - 6;
  int colCount= cast(int)gnames.length;

  foreach(line; rows[5..$]){
    if(line != ""){
      string[] row = line.split("\t");
      string id = row[0];
      foreach(dchar item; row[1]){
        gs2 ~= faster_lmm_d_mapper[hab_mapper[item]];
      }
    }
  }
  info("Genotype Matrix created");

  return genoObj(dmatrix([rowCount, colCount], gs2), gnames);
}