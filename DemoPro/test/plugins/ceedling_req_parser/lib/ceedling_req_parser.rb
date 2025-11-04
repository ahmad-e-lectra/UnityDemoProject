require 'ceedling/plugin' # DEVE ESSERE INCLUSO
require 'csv'

class CeedlingReqParser < Plugin # <-- EREDITA DA PLUGIN
  
  # --- Configurazione ---
  REQUIREMENT_REGEX = /^\s*\/\/\s*REQ:\s*(.+)/
  TEST_FUNCTION_REGEX = /^\s*void\s+test_(.+)\s*\(/ 
  OUTPUT_CSV_FILE = 'requirements_traceability.csv'
  
  def setup
	parse_test_files
  end
  
  private

  def parse_test_files
    path = 'test/**/*.c' # Assuming a standard Ceedling project structure

    traceability_data = []
    current_requirement = 'NONE'
	
	Dir.glob(path).each do |file_path|
	  File.readlines(file_path).each do |line|
	  
	    # 1. Look for the Requirement ID tag
        if (match = line.match(REQUIREMENT_REGEX))
          current_requirement = match[1].strip # Capture the ID and strip whitespace
      
        # 2. Look for the test function name immediately following the REQ tag
        elsif (match = line.match(TEST_FUNCTION_REGEX))
          test_name = "test_#{match[1].strip}"
          file_name = File.basename(file_path)
      
          # Add the link to our data structure
          traceability_data << {
            requirement_id: current_requirement,
            test_file: file_name,
            test_function: test_name
          }
      
          # Reset the requirement ID for the next test function
          current_requirement = 'NONE' 
        end
      end
    end

    write_csv(traceability_data)
  end
  
  def write_csv(data)
    CSV.open(OUTPUT_CSV_FILE, "wb") do |csv|
      csv << ["Requirement ID", "Test File", "Test Function"]
      data.each do |item|
        csv << [item[:requirement_id], item[:test_file], item[:test_function]]
      end
    end
    puts "✅ CSV di tracciabilità generato: #{OUTPUT_CSV_FILE}"
  end
end