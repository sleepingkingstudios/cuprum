# spec/cuprum_spec.rb

require 'cuprum'

RSpec.describe Cuprum do
  shared_context 'when the warning proc is set' do
    around(:example) do |example|
      begin
        default_proc = described_class.send(:warning_proc)

        example.call
      ensure
        described_class.warning_proc = default_proc
      end # begin-ensure
    end # around
  end # shared_context

  describe '::VERSION' do
    it 'should define the constant' do
      expect(described_class).
        to have_constant(:VERSION).
        with_value(Cuprum::Version.to_gem_version)
    end # it
  end # describe

  describe '::version' do
    it 'should define the reader' do
      expect(described_class).
        to have_reader(:version).
        with_value(Cuprum::Version.to_gem_version)
    end # it
  end # describe

  describe '::warn' do
    let(:message) do
      'Unable to log you out because you are not logged in. Please log in so ' \
      'you can log out.'
    end # let

    it 'should define the method' do
      expect(described_class).to respond_to(:warn).with(1).argument
    end # it

    it 'should delegate to Kernel#warn' do
      allow(Kernel).to receive(:warn)

      described_class.warn(message)

      expect(Kernel).to have_received(:warn).with(message)
    end # it

    wrap_context 'when the warning proc is set' do
      let(:warning_proc) { instance_double(Proc, :call => nil) }

      before(:example) do
        described_class.warning_proc = warning_proc
      end # before example

      it 'should call the warning proc' do
        described_class.warn(message)

        expect(warning_proc).to have_received(:call).with(message)
      end # it
    end # wrap_context
  end # describe

  describe '::warning_proc' do
    it 'should define the private class reader' do
      expect(described_class).
        to have_reader(:warning_proc, :allow_private => true)
    end # it

    it 'should return a proc' do
      expect(described_class.send :warning_proc).to be_a Proc
    end # it
  end # describe

  describe '::warning_proc=' do
    it 'should define the class writer' do
      expect(described_class).to have_writer(:warning_proc=)
    end # it
  end # describe
end # describe
