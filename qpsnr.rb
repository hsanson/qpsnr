#!/usr/bin/env ruby1.9.1
# encoding: UTF-8

DATA=<<-END
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>{{SOURCE}}</title>
    <script language="javascript" type="text/javascript" src="./scripts/jquery.js"></script>
    <script language="javascript" type="text/javascript" src="./scripts/jquery.flot.js"></script>
    <script language="javascript" type="text/javascript" src="./scripts/jquery.flot.crosshair.js"></script>
    <style type="text/css">
      #placeholder {
        width: 1700px;
        height: 300px;
      }
      #imgcontainer {
        width: 90%;
        margin-left: auto;
        margin-right: auto;
      }
      #original {
       background: grey;
       float: left;
       margin-left: auto;
       margin-right: 2px;
       width: 40%;
      }
      #original img {
        width:100%;
      }
      #original_name {
        width: 100%;
        margin-left: auto;
        margin-right: auto;
      }

      #encoded {
       background: grey;
       float: left;
       margin-right: auto;
       margin-left: 2px;
       width: 40%;
      }
      #encoded img {
        width:100%;
      }
      #encoded_name {
        width: 100%;
        margin-left: auto;
        margin-right: auto;
      }

      #controls {
       clear: both;
       width: 30%;
       margin-left: auto;
       margin-right: auto;
      }

    </style>
  </head>
  <body>
    <div id="imgcontainer">
      <div id="original">
        <img id="original_img" />
        <div id="original_name">{SOURCE}</div>
      </div>
      <div id="encoded">
        <img id="encoded_img" />
        <div id="encoded_name" />
      </div>
    </div>
    <div id="controls">
    </div>
    <div id="placeholder"></div>

    <script type="text/javascript">
      $(function() {
          var current_ssim = {VALUE};
          var current_frame = {FRAME};
          var current_series = 0;
          var max_frame = {MAX};
          var min_frame = {MIN};
          var series = [ {ITEMS} ];

          function zeroFill(number, width) {
            width -= number.toString().length;
            if ( width > 0 ) {
              return new Array( width + (/\./.test( number ) ? 2 : 1) ).join( '0' ) + number;
            }
            return number + "";
          }

          var plot = $.plot($("#placeholder"), 
              [ {DATA} ], {
              series: {
                lines: { show: true, fill: false },
                points: { show: true, fill: false }
              },
              grid: { hoverable: true, clickable: true },
              crosshair: { mode: "x" }
          });

          var data = plot.getData();

          function getSSIM(frame, series, data) {
            var s = data[series];
            for(j = 0; j < s.data.length; j++) {
              if(s.data[j][0] >= frame) {
                return s.data[j][1].toFixed(6);
              }
            }
          }

          function page(frame, serie, ssim) {
            $("#original_img").attr("src", '{BASENAME}/{SOURCE}' + '.' + zeroFill(frame, 7) + '.jpeg');
            $("#encoded_img").attr("src", '{BASENAME}/' + series[serie] + '.' + zeroFill(frame, 7) + '.jpeg');
            //ssim = data[current_item].data[current_frame - 1][1];
            $("#encoded_name").text(series[serie] + ' FRAME: ' + frame.toString() + ' SSIM: ' + ssim.toString() );
            plot.unhighlight();
            plot.highlight(serie, [frame, ssim]);
            plot.lockCrosshair({ x: frame, y: ssim });
            console.log("Current : " + ' ' + series[serie] + ' FRAME: ' + frame.toString() + ' SSIM: ' + ssim );
          }

          $("#placeholder").bind('plotclick', function(event, pos, item) {
            if(item) {
              current_frame = parseInt(item.datapoint[0].toFixed(0));
              //current_ssim = parseInt(item.datapoint[1].toFixed(4));
              current_series = series.indexOf(item.series.label);
              current_ssim = getSSIM(current_frame, current_series, data);
              page(current_frame, current_series, current_ssim);
            }
          });

          page(current_frame, current_series, current_ssim);

          $("body").keydown(function(event) {
            if (event.which == 37) {
              if(current_frame > min_frame) {
                current_frame = current_frame - 1;
              } else {
                current_frame = max_frame;
              }
            } else if(event.which == 39) {
              if((current_frame + 1) <= max_frame) {
                current_frame = current_frame + 1;
              } else {
                current_frame = min_frame;
              }
            } else if(event.which == 38) {
              if(current_series <= 0) {
                current_series = series.length - 1;
              } else {
                current_series = current_series - 1;
              }
            } else if(event.which == 40) {
              current_series = (current_series + 1)%series.length;
            }
            //current_ssim = data[current_series]
            current_ssim = getSSIM(current_frame, current_series, data);
            page(current_frame, current_series, current_ssim);
          });
      });
    </script>
  </body>

</html>
END

require "optparse"
require "ostruct"
require "fileutils"

# Utility method to change working directory
def cwd dir
  original_dir = Dir.pwd
  begin
    puts "Creating #{dir} directory"
    FileUtils.mkdir_p(dir)
    Dir.chdir dir
    yield
  ensure
    Dir.chdir original_dir
  end
end


options = OpenStruct.new
options.library = {}
options.library[:ana] = :ssim
options.library[:log] = 3
options.library[:color] = :rgb
options.library[:bs] = 8
options.inplace = false
options.encoding = "utf8"
options.transfer_type = :auto
options.verbose = false

opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename __FILE__} [options] -r REFERENCE  INPUT1 INPUT2 ..."
  opts.separator ""
  opts.separator "Specific options: "
  opts.on("-r", "--reference REF", "Reference REF") { |lib| options.library[:ref] = lib }
  opts.on("-m", "--max-frames [MAXFRAMES]", "set max frames to process before quit") { |lib| options.library[:max] = lib }
  opts.on("-s", "--skip-frames [SKIPFRAMES]", "skip n initial frames") { |lib| options.library[:skip] = lib }
  opts.on("-a", "--analyzer ANALYZER", [:psnr, :ssim], "psnr, ssim (default)") { |lib| options.library[:ana] = lib }
  opts.on("-l", "--loglevel LEVEL", [0, 1, 2, 3, 4], "0: no log, 1: errors, 2: warnings, 3: info (default), 4: debug") { |lib| options.library[:ana] = lib }
  opts.on("-c", "--colorspace [SPACE]", [:rgb, :hsi, :ycbcr, :y], "color space to use (PSNR only): rgb, hsi, ycbcr or y (default rgb)") { |lib| options.library[:color] = lib }
  opts.on("-bs", "--block-size BS", "block size used in SSIM analysis (default 8)") { |lib| options.library[:bs] = lib }
end

opts.parse!(ARGV)

if options.library[:ref].nil?
  puts "Missing reference clip (-r) argument"
  exit -1
end

if ARGV.empty?
  puts "Missing input clips"
end

files = ARGV.join(" ")
ARGV.each do |f|
  if ! File.exists?(f) or ! File.readable?(f)
    puts "File #{f} does not exists or is not readable"
    exit
  end
end

#qpsnr_cmd = "/usr/bin/qpsnr -a ssim -I -m 10 -r #{ARGV.join(" ")}"
qpsnr_cmd = "#{File.dirname(__FILE__)}/qpsnr "
qpsnr_cmd += "-a #{options.library[:ana]} -J -G "
qpsnr_cmd += "-m #{options.library[:max]} " if options.library[:max].to_i > 0
qpsnr_cmd += "-s #{options.library[:skip]} " if options.library[:skip].to_i > 0
qpsnr_cmd += "-o colorspace=#{options.library[:color]}:blocksize=#{options.library[:bs]} "
qpsnr_cmd += "-r #{options.library[:ref]} "
qpsnr_cmd += "#{ARGV.join(" ")}"

#puts "== Running qpsnr on input files"
puts qpsnr_cmd

data = []
links = ""

result = ""
dirname = File.dirname options.library[:ref]
extname = File.extname options.library[:ref]
basename = File.basename options.library[:ref], extname

cwd basename do
  result = `#{qpsnr_cmd}`
  result.split.each do |line|
      values = line.split(",")
      next if values[0] == "Sample"
      ARGV.size.times do |col|
        data[col] ||= []
        data[col] << [values[0].to_i, values[col + 1].to_f]
      end
  end
end

File.open("#{basename}.dat", "w") { |fp| fp << result }

min = (options.library[:skip] || 0).to_i + 1
max = min + data[0].size - 1
ssim = data[0][0][1]
frame = data[0][0][0]

# Convert data to a string for flot
data = data.each_with_index.map do |x, i|
  "{ data: #{x.to_s}, label: '#{File.basename(ARGV[i])}' }"
end.join(",")

FileUtils.mkdir_p("scripts")
FileUtils.cp(File.join(File.dirname(__FILE__), "scripts", "jquery.js"), "scripts/")
FileUtils.cp(File.join(File.dirname(__FILE__), "scripts", "jquery.flot.js"), "scripts/")
FileUtils.cp(File.join(File.dirname(__FILE__), "scripts", "jquery.flot.crosshair.js"), "scripts/")

File.open("#{basename}.html", "w") do |fp|
 fp << DATA.gsub("{SOURCE}", "#{basename}#{extname}")
         .gsub("{BASENAME}", basename)
         .gsub("{MAX}", max.to_s )
         .gsub("{MIN}", min.to_s )
         .gsub("{VALUE}", ssim.to_s )
         .gsub("{FRAME}", frame.to_s )
         .gsub("{ITEMS}", ARGV.map { |a| "'#{File.basename(a)}'" }.join(",").to_s)
         .gsub("{DATA}", data.to_s)
end
