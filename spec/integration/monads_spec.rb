RSpec.describe(Dry::Monads) do
  let(:m) { described_class }
  list = Dry::Monads::List

  maybe = Dry::Monads::Maybe
  some = maybe::Some.method(:new)

  result = Dry::Monads::Result
  success = result::Success.method(:new)
  failure = result::Failure.method(:new)

  validated = Dry::Monads::Validated
  valid = validated::Valid.method(:new)
  invalid = validated::Invalid.method(:new)

  describe 'Maybe' do
    describe '.Maybe' do
      describe 'mapping to Some' do
        subject { m.Some(5) }

        it { is_expected.to eql(some.(5)) }
      end

      describe 'mapping to None' do
        subject { m.Maybe(nil) }

        it { is_expected.to be_none }
      end
    end

    describe '.Some' do
      context 'with a value' do
        subject { m.Some(10) }

        it { is_expected.to eql(some.(10)) }

        example 'mapping nil produces an error' do
          expect { m.Some(nil) }.to raise_error(ArgumentError)
        end
      end

      describe 'lifting a block' do
        let(:block) { -> _ { Integer } }
        subject { m.Some(&block) }

        it { is_expected.to eql(some.(block)) }
      end

      example 'using without values produces an error' do
        expect { m.Some() }.to raise_error(ArgumentError, 'No value given')
      end
    end

    describe '.None' do
      subject { m.None() }

      it { is_expected.to be_none }
    end
  end

  describe 'List' do
    subject(:instance) do
      module Test
        class Foo
          include Dry::Monads

          def get_list
            List[1, 2, 3]
          end
        end
      end

      Test::Foo.new
    end

    it 'builds a list with List[]' do
      expect(instance.get_list).to eql(list[1, 2, 3])
    end
  end

  describe 'Result' do
    describe '.Success' do
      subject { m.Success('everything went right') }

      it { is_expected.to eql(success.('everything went right')) }
    end

    describe '.Failure' do
      subject { m.Failure('something has gone wrong') }

      it { is_expected.to eql(failure.('something has gone wrong')) }
    end
  end

  describe 'Validated' do
    describe '.Valid' do
      subject { m.Valid('ok') }

      it { is_expected.to eql(valid.('ok')) }

      it 'accepts a block' do
        fn = -> x { x }
        expect(m.Valid(&fn)).to eql(valid.(fn))
      end

      it 'raises an argument error if no value provided' do
        expect { m.Valid() }.to raise_error(ArgumentError, 'No value given')
      end
    end

    describe '.Invalid' do
      subject { m.Invalid(:not_ok) }

      it { is_expected.to eql(invalid.(:not_ok)) }

      it 'accepts a block' do
        fn = -> x { x }
        expect(m.Invalid(&fn)).to eql(invalid.(fn))
      end

      it 'raises an argument error if no value provided' do
        expect { m.Invalid() }.to raise_error(ArgumentError, 'No value given')
      end
    end
  end
end
