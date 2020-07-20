using Spider
using Test

@testset "Basic site generation" begin
  args = (source_dir="basic_src",
          output_dir="basic_output",
          clear_output_dir=true,
          header_file="basic_header.html",
          footer_file="basic_footer.html")

  run_spider(;args...)
  @test isfile("basic_output/index.html")
end

run(`rm -fr basic_output`)

nothing
