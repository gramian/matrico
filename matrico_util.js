
function echo(m)
{
	var o = "";

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
		o = o + "\n";
	}
	o = o + "\n";

	return o;
}

function tic()
{

}

function toc()
{

}

function isnumeric()
{

}

