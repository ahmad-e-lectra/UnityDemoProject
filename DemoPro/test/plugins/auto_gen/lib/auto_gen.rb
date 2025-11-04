require 'ceedling/plugin'
require 'rake'  # Needed to define custom tasks

class AutoGen < Plugin
  SRC_DIR  =  ['src','../src/**','../MyCode/**'] 
  TEST_DIR = 'test'

  STUB_TEMPLATE = %(
void test_%{func}usecase(void)
{

}
)

  INVALID_NAMES = %w[if for while switch return else do].freeze

  def setup
    # Register a custom Rake task for Ceedling
    #Rake::Task.define_task(:autogen) do --------> For Manual Stub Generation
      generate_test_stubs
    #end
  end

  # Also run automatically before tests
  def pre_test_build
    generate_test_stubs
    puts "\n[AutoGen] Scanning source files for new functions...\n\n"
  end

  private

  def generate_test_stubs
  puts "\n[AutoGen] Scanning source files for new functions...\n\n"

  Array(SRC_DIR).each do |src_dir|       # ✅ Loop through each directory
    Dir.glob(File.join(src_dir, '**', '*.c')).each do |src_path|
      module_name = File.basename(src_path, '.c')
      test_file   = File.join(TEST_DIR, "test_#{module_name}.c")
      next unless File.exist?(test_file)

      funcs = extract_functions(src_path)
      update_test_file(test_file, funcs) unless funcs.empty?
    end
  end

  puts "\n[AutoGen] Done scanning.\n\n"
end

  def extract_functions(file_path)
    code = File.read(file_path)
    pattern = /^[\w\s\*\_]+?\s+([A-Za-z_]\w*)\s*\([^;{]*\)\s*\{/
    funcs = code.scan(pattern).flatten
    funcs.reject { |fn| INVALID_NAMES.include?(fn) }
  end

  def update_test_file(test_file, funcs)
    content = File.read(test_file)
    insertion_index = content.index('#endif') || content.length
    added = []

    new_stubs = funcs.each_with_object('') do |fn, out|
      unless content.include?("test_#{fn}")
        out << STUB_TEMPLATE % { func: fn }
        added << fn
      end
    end

    if added.empty?
      puts "✅ No new functions to add in #{File.basename(test_file)}"
      return
    end

    updated_content = content.dup.insert(insertion_index, + new_stubs + "\n")
    File.write(test_file, updated_content)

    puts "➕ Added #{added.size} new test stubs to #{File.basename(test_file)}:"
    added.each { |fn| puts "    → test_#{fn}usecase(void)" }
  end
end
