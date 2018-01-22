# encoding: utf-8
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'httparty'

module MorpherInflect
  # Число доступных вариантов склонений
  INFLECTIONS_COUNT = 6

  # Класс для получения данных с веб-сервиса Морфера.
  class Inflection
    include HTTParty
    base_uri 'ws3.morpher.ru'

    # Получить склонения для имени <tt>name</tt>
    def get(text)
      options = {}
      options[:query] = { s: text, format: 'json' }
      self.class.get("/russian/declension", options)
    end
  end

  class << self
    # Кеширование успешных результатов запроса к веб-сервису
    @@cache = {}

    # Возвращает массив склонений (им., род., дат., вин., твор., предл.) для слова word.
    #
    # Если слово не найдено в словаре, в массиве вместо всех склонений будет word.
    # Повторяет исторический API gem yandex-inflect.
    def inflections(word)
      lookup = cache_lookup(word)
      return lookup if lookup

      response = Inflection.new.get(word) rescue nil
      if response && response.code == 200
        # Морфер вернул хеш склонений
        inflections = successful_result(word, response)
        # Кладем в кеш
        cache_store(word, inflections)
      else
        # Морфер вернул код ошибки (слово не найдено в словаре),
        # Забиваем оригинальным словом
        inflections = problematic_result(word)
        # Не сохраняем в кэше, может в другой раз больше повезет.
      end
      inflections
    end

    def clear_cache
      @@cache.clear
    end

    private

    def successful_result(word, response)
      [word] + response.parsed_response.values_at(*%W(Р Д В Т П))
    end

    def problematic_result(word)
      Array.new(INFLECTIONS_COUNT, word)
    end

    def cache_lookup(word)
      @@cache[word.to_s]
    end

    def cache_store(word, value)
      @@cache[word.to_s] = value
    end
  end
end
