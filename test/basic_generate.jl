using Spider
using Test

@testset "Basic site generation" begin
  args = (source_dir="basic_src",
          output_dir="basic_output",
          clear_output_dir=true,
          header_file="basic_header.html",
          footer_file="basic_footer.html")

  run_spider(;args...)
  # Check html generated from Markdown:
  @test isfile("basic_output/index.html")
  # Check non-Markdown files copied:
  @test isfile("basic_output/style.css")
end

run(`rm -fr basic_output`)

nothing
