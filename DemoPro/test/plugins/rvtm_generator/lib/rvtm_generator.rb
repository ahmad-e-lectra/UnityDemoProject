require 'ceedling/plugin' # DEVE ESSERE INCLUSO
require 'csv'
require 'nokogiri'

# La classe non eredita da Plugin
class RvtmGenerator < Plugin
  
  # --- Configurazione ---
  CSV_FILE = 'requirements_traceability.csv'
  XML_FILE = 'build/artifacts/test/report.xml' # Standard Ceedling output path
  OUTPUT_FILE = 'rvtm_report.csv'
  
  def setup
    @test_counter = 0
  end

  def post_build
    generate_rvtm()
  end

  private

  def generate_rvtm
    requirement_map = Hash.new { |hash, key| hash[key] = [] }
    test_results = {}
    
    parse_csv(requirement_map)
    parse_xml(test_results)
    generate_report(requirement_map, test_results)
  end

  # --- LOGICA DI PARSING DEI DATI ---

  def parse_csv(requirement_map)
    puts "\n📝 Parsing traceability CSV: #{CSV_FILE}..."
    unless File.exist?(CSV_FILE)
      puts "❌ ERRORE: CSV file non trovato in #{CSV_FILE}. Eseguire prima 'ceedling req:parse'."
      exit(1)
    end
    CSV.foreach(CSV_FILE, headers: true) do |row|
      req_id = row['Requirement ID']
      test_func = row['Test Function']
      if req_id && test_func
        requirement_map[req_id.strip] << test_func.strip
      end
    end
    puts "   -> Caricati #{requirement_map.keys.count} requisiti con test collegati."
  end

  def parse_xml(test_results)
    puts "📊 Parsing Custom XML test report: #{XML_FILE}..."
    unless File.exist?(XML_FILE)
      puts "❌ ERRORE: XML file non trovato in #{XML_FILE}. Eseguire prima 'ceedling test:all'."
      exit(1)
    end
    
    xml_doc = Nokogiri::XML(File.read(XML_FILE))
    
    # Processa Test Falliti (FAIL)
    xml_doc.xpath('//FailedTests/Test').each do |test_node|
      test_name_full = test_node.at_xpath('Name')&.text
      if test_name_full
        test_function_name = test_name_full.split('::').last
        test_results[test_function_name] = 'FAIL'
      end
    end

    # Processa Test Riusciti e Ignorati (PASS)
    xml_doc.xpath('//SuccessfulTests/Test | //IgnoredTests/Test').each do |test_node|
      test_name_full = test_node.at_xpath('Name')&.text

      if test_name_full
        test_function_name = test_name_full.split('::').last
        unless test_results[test_function_name] == 'FAIL'
          test_results[test_function_name] = 'PASS'
        end
      end
    end
    
    puts "   -> Caricati #{test_results.keys.count} risultati dei test."
  end
  
  # --- LOGICA DI GENERAZIONE REPORT ---

  def generate_report(requirement_map, test_results)
    puts "📑 Generazione RVTM: #{OUTPUT_FILE}..."
    final_report = []

    requirement_map.each do |req_id, test_functions|
      req_status = 'NO COVERAGE'
      failed_tests = []
      
      test_functions.each do |test_func|
        status = test_results[test_func]
        if status == 'FAIL'
          failed_tests << test_func
          req_status = 'FAIL'
        elsif status == 'PASS'
          req_status = 'PASS' unless req_status == 'FAIL'
        end
      end

      final_report << {
        'Requirement ID' => req_id,
        'Verification Status' => req_status,
        'Linked Tests' => test_functions.join(', '),
        'Failing Tests' => failed_tests.empty? ? 'N/A' : failed_tests.join(', ')
      }
    end

    CSV.open(OUTPUT_FILE, "wb") do |csv|
      csv << final_report.first.keys if final_report.any?
      final_report.each { |row| csv << row.values }
    end
    
    puts "✅ Generazione RVTM Completata. Output salvato in #{OUTPUT_FILE}"
  end
end