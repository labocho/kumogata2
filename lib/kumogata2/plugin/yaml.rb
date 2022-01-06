require 'yaml'

class Kumogata2::Plugin::YAML
  Kumogata2::Plugin.register(:yaml, ['yaml', 'yml', 'template'], self)

  # Register tags to parse abbreviated function call like `!Ref: Foo`
  # See: https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference.html
  %w(And Base64 Cidr Equals FindInMap GetAZs If ImportValue Join Not Or Select Split Sub Transform).each do |tag|
    YAML.add_domain_type("", tag) do |type, value|
      {"Fn::" + tag => value}
    end
  end

  YAML.add_domain_type("", "GetAtt") do |type, value|
    {"Fn::GetAtt" => value.split(".")}
  end

  YAML.add_domain_type("", "Ref") do |type, value|
    {"Ref" => value}
  end

  def initialize(options)
    @options = options
  end

  def parse(str)
    YAML.load(str)
  end

  def dump(hash, color = true, compact: false)
    return JSON.generate(hash) if compact

    Hashie.stringify_keys!(hash)
    if color
      YAML.dump(hash).colorize_as(:yaml)
    else
      YAML.dump(hash)
    end
  end
end
