describe HttpStub::Extensions::Core::Hash::IndifferentAndInsensitiveAccess do

  let(:testable_class) { Class.new(::Hash).tap { |hash_class| hash_class.send(:include, described_class) } }

  let(:indifferent_and_insensitive_access_hash) { testable_class.new }

  before(:example) { indifferent_and_insensitive_access_hash.merge!(original_hash) }

  describe "#[]" do

    subject { indifferent_and_insensitive_access_hash[key] }

    context "when the original hash contains symbol keys" do

      let(:original_hash) { { key: "value", another_key: "another value" } }

      context "and the provided key is a symbol" do

        context "that exactly matches an original hash key" do

          let(:key) { :key }

          it "returns the original value" do
            expect(subject).to eql("value")
          end

          context "and another key is also a case insensitive match" do

            let(:original_hash) { { Key: "Case insensitive value", key: "value" } }

            it "prefers the exact match" do
              expect(subject).to eql("value")
            end

          end

        end

        context "that is a case insensitive match for an original hash key" do

          let(:key) { :Key }

          it "returns the original value" do
            expect(subject).to eql("value")
          end

        end

        context "that does not match an entry in the original hash" do

          let(:key) { :does_not_match }

          it "returns nil" do
            expect(subject).to be(nil)
          end

        end

      end

      context "and the provided key is a string" do

        context "whose symbol respresentation exactly matches an original hash key" do

          let(:key) { "key" }

          it "returns the original value" do
            expect(subject).to eql("value")
          end

        end

        context "whose symbol representation is a case insensitive match for an original hash key" do

          let(:key) { "Key" }

          it "returns the original value" do
            expect(subject).to eql("value")
          end

        end

        context "that does not match an entry in the original hash" do

          let(:key) { "does not match" }

          it "returns nil" do
            expect(subject).to be(nil)
          end

        end

      end

    end

    context "when the original hash contains string keys" do

      let(:original_hash) { { "key" => "value", "another_key" => "another value" } }

      context "and the provided key is a string" do

        context "that exactly matches an original hash key" do

          let(:key) { "key" }

          it "returns the original value" do
            expect(subject).to eql("value")
          end

          context "and another key is also a case insensitive match" do

            let(:original_hash) { { "Key" => "Case insensitive value", "key" => "value" } }

            it "prefers the exact match" do
              expect(subject).to eql("value")
            end

          end

        end

        context "that is a case insensitive match for an original hash key" do

          let(:key) { "Key" }

          it "returns the original value" do
            expect(subject).to eql("value")
          end

        end

        context "that does not match an entry in the original hash" do

          let(:key) { "does not match" }

          it "returns nil" do
            expect(subject).to be(nil)
          end

        end

      end

      context "and the provided key is a symbol" do

        context "whose string respresentation exactly matches an original hash key" do

          let(:key) { :key }

          it "returns the original value" do
            expect(subject).to eql("value")
          end

        end

        context "whose string representation is a case insensitive match for an original hash key" do

          let(:key) { :Key }

          it "returns the original value" do
            expect(subject).to eql("value")
          end

        end

        context "that does not match an entry in the original hash" do

          let(:key) { :does_not_match }

          it "returns nil" do
            expect(subject).to be(nil)
          end

        end

      end

    end

  end

end
