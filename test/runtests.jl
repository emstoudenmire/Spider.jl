using Test

@testset "Spider.jl" begin
  @testset "$filename" for filename in (
    "basic_generate.jl",
  )
    println("Running $filename")
    include(filename)
  end
end
