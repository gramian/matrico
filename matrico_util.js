
function echo(m,n)
{
	var o = n + " = \n";

	var r = matrico_core.size(m,1);
	var c = matrico_core.size(m,2);
	var v = 0;

	for(var i=0;i<r;i++)
	{
		o += " ";
		for(var j=0;j<c;j++)
		{
			v = matrico_core.at(m,i,j);
			if(v>=0) { o += " "; }
			o += v.toFixed(4) + " ";
		}
		o += "\n";
	}
	o += "\n";

	document.getElementById("out").innerHTML += o;

	return;
}

var timer = 0;

function tic()
{
	timer = Date.now();
}

function toc(t)
{
	return timer - Date.now();
}

function isnumeric(s)
{
	return !isNaN(+s) && isFinite(s);
}

