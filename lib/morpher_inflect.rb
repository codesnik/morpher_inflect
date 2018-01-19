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

  # Кеширование успешных результатов запроса к веб-сервису
  @@cache = {}

  # Возвращает массив склонений (размером <tt>INFLECTIONS_COUNT</tt>) для слова <tt>word</tt>.
  #
  # Если слово не найдено в словаре, будет возвращен массив размерностью <tt>INFLECTIONS_COUNT</tt>,
  # заполненный этим словом.
  def self.inflections(word)
    inflections = []

    lookup = cache_lookup(word)
    return lookup if lookup

    response = Inflection.new.get(word) rescue nil # если поднято исключение
    return inflections.fill(word, 0..INFLECTIONS_COUNT-1) if response.nil?

    case response.code
      when 200
        # Морфер вернул хеш склонений
        inflections = [word] + JSON.parse(response.body).values
        # Кладем в кеш
        cache_store(word, inflections)
      else
        # Морфер вернул код ошибки (слово не найдено в словаре),
        # Забиваем оригинальным словом
        inflections.fill(word, 0..INFLECTIONS_COUNT-1)
    end

    inflections
  end

  # Очистить кеш
  def self.clear_cache
    @@cache.clear
  end

  private
    def self.cache_lookup(word)
      @@cache[word.to_s]
    end

    def self.cache_store(word, value)
      @@cache[word.to_s] = value
    end
end
