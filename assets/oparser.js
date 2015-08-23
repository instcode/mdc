
// Widget tree property mapping
//~ by eminem
//~ Dec 6th.2o13

var path = require('path');
var fs = require('fs');

function walkSub(sub, jsar)
{
	var subs = [];
	var files = fs.readdirSync(sub);
	for(var i=0;i<files.length;++i)
	{
		var f = path.join(sub,files[i]);
		if(fs.statSync(f).isDirectory())
		{
			subs.push(f);
		}

		var s = f.toLowerCase();
		if( /\.JSON$/i.exec(s) )
		{
			jsar.push(s);
		}
	}

	// Recursively
	for(var i=0;i<subs.length;++i)
	{
		walkSub(subs[i], jsar);
	}
}

function insertOne(dc, js, obj)
{
	if( js[obj] === null )
	{
		if( ! dc[obj] )
		{
			dc[obj] = 'null';
		}
	}
	else if ( typeof(js[obj]) === 'object' )
	{
		dc[obj] = 'object';
	}
	else if ( typeof(js[obj]) === 'boolean' )
	{
		dc[obj] = 'bool';
	}
	else if(typeof(js[obj])==='string')
	{
		dc[obj] = 'std::string';
	}
	else if(typeof(js[obj])==='number')
	{
		if( dc[obj] === 'float' )
		{
			// good enough
		}
		else if( dc[obj] !== 'float' )
		{
			var v = js[obj].toString();
			if( v.indexOf('.') >= 0)
			{
				dc[obj] = 'float';
			}

			if( /X$/i.exec(obj) )
			{
				dc[obj] = 'float';
			}

			if( /Y$/i.exec(obj) )
			{
				dc[obj] = 'float';
			}

			if( /width$/i.exec(obj) )
			{
				dc[obj] = 'float';
			}

			if( /height$/i.exec(obj) )
			{
				dc[obj] = 'float';
			}

			// fail safe
			if( ! dc[obj] )
			{
				dc[obj] = 'int';
			}
		}
		else
		{
			dc[obj] = 'int';
		}
	}
	else
	{
		dc[obj] = 'std::string';	//by default
	}
}

function iterateOpts(js, dc)
{
	for(var o in js)
	{
		insertOne(dc, js, o );
	}
}

function walkTree(js, dc)
{
	if( ! js )
	{
		return;
	}

	if(js.options)
	{
		iterateOpts(js.options, dc);
	}

	if( js.children && Array.isArray(js.children) )
	{
		for(var i=0;i<js.children.length;++i)
		{
			walkTree(js.children[i], dc);
		}
	}
}

function processJson(path, dc)
{
	try
	{
		console.log('processing ' + path);
		var obj = require(path);
		// console.log('OK for ' + path);
		walkTree(obj.widgetTree, dc);
	}
	catch(e)
	{
		// console.error(e);
	}
}

function writeToHeader(dc, outPath)
{
	var data = '\n\n\n';
	data    += '#ifndef __OPTS_HEADER_DEF_H__GEN__\n';
	data    += '#define __OPTS_HEADER_DEF_H__GEN__\n\n\n';

	data    += '#include <string>\n';
	data    += '\n\n';

	data    += 'struct XNodeOptions\n';
	data    += '{\n';
	for(var name in dc)
	{
		data += '  ' + dc[name] + ' ' + name + ';\n';
	}

	data    += '};\n\n';
	data    += '#endif\n';

	fs.writeFileSync(outPath, data, 'utf8');
}


// Starts here
var curd = path.resolve('.');
var ar = [];
walkSub(curd, ar);
var opDc = {};
console.log(ar.length + ' JSON(s) in all');

for(var i=0;i<ar.length;++i)
{
	processJson(ar[i], opDc);
}

console.log(opDc);
writeToHeader(opDc, path.resolve(curd,'../Classes/utils/xnode/XNodeOptions.h'));


