export ArgDict

function pause() 
  a = readline()
  (length(a) == 0) && return
  (a[1]=='q') && exit(0)
end

function getArg(args,
                key::Symbol,
                default=Nothing)
  if haskey(args,key)
    return args[key]
  end
  if default == Nothing
    throw(ArgumentError("key $key not found in argument dictionary"))
  end
  return default
end
