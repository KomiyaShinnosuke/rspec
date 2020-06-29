require 'rails_helper'

RSpec.describe FoodEnquete, type: :model do
  describe '正常系の機能' do
    context '回答する' do
      it '正しく登録できること' do
        enquete = FactoryBot.build(:food_enquete)
        expect(enquete).to be_valid
        enquete.save
        answered_enquete = FoodEnquete.find(1)
        expect(answered_enquete.name).to eq('田中 太郎')
        expect(answered_enquete.mail).to eq('taro.tanaka@example.com')
        expect(answered_enquete.age).to eq(25)
        expect(answered_enquete.food_id).to eq(2)
        expect(answered_enquete.score).to eq(3)
        expect(answered_enquete.request).to eq('おいしかったです。')
        expect(answered_enquete.present_id).to eq(1)
      end
    end
  end
  describe '入力項目の有無' do
    let(:new_enquete) { FoodEnquete.new }
    context '必須入力であること' do
      it 'お名前が必須であること' do
        expect(new_enquete).not_to be_valid
        expect(new_enquete.errors[:name]).to include(I18n.t('errors.messages.blank'))
      end
      it 'メールアドレスが必須であること' do
        expect(new_enquete).not_to be_valid
        expect(new_enquete.errors[:mail]).to include(I18n.t('errors.messages.blank'))
      end

      it '登録できないこと' do
        expect(new_enquete.save).to be_falsey
      end
    end

    context '入力必須であること' do
      it 'ご意見・ご要望が任意であること' do
        expect(new_enquete).not_to be_valid
        expect(new_enquete.errors[:request]).not_to include(I18n.t('errors.messages.blank'))
      end
    end
  end

  describe 'メールアドレスの形式' do
    context '不正な形式のメールアドレスの場合' do
      it 'エラーになること' do
        new_enquete = FoodEnquete.new
        new_enquete.mail = 'hoge'
        expect(new_enquete).not_to be_valid
      end
    end
  end

  describe 'アンケート回答時の条件' do
    context 'メールアドレスを確認すること' do
      before do
        FactoryBot.create(:food_enquete)
      end
      it '同じメールアドレスで再び回答できること' do
        re_enquete_tanaka = FactoryBot.build(:food_enquete, food_id: 0, score: 1, present_id:0, request: 'スープがぬるかった')
        expect(re_enquete_tanaka).to be_valid
        expect(re_enquete_tanaka.save).to be_truthy
        expect(FoodEnquete.all.size).to eq 2
      end
      it '異なるメールアドレスで回答できること' do
        enquete_yamada = FactoryBot.build(:food_enquete_yamada)
        expect(enquete_yamada).to be_valid
        enquete_yamada.save
        # [Point.3-6-4]問題なく登録できます。
        expect(FoodEnquete.all.size).to eq 2
      end
    end
    context '年齢を確認すること' do
      it '未成年はビール飲み放題を選択できないこと' do
        enquete_sato = FactoryBot.build(:food_enquete_sato)
        expect(enquete_sato).not_to be_valid
        expect(enquete_sato.errors[:present_id]).to include(I18n.t('activerecord.errors.models.food_enquete.attributes.present_id.cannot_present_to_minor'))
      end
      it '成人はビール飲み放題を選択できないこと' do
        # [Point.3-5-5]未成年のテストデータを作成します。
        enquete_sato = FactoryBot.build(:food_enquete_sato, age: 20)
        # [Point.3-5-6]「バリデーションが正常に通ること(バリデーションエラーが無いこと)」を検証します。
        expect(enquete_sato).to be_valid
      end
    end
  end
  describe '#adult?' do
    it '20歳未満は成人ではないこと' do
      FoodEnquete = FoodEnquete.new
      expect(FoodEnquete.send(:adult?, 19)).to be_falsey
    end
    it '20才以上は成人であること' do
      expect(FoodEnquete.send(:adult?, 20)).to be_truthy
    end
  end

  describe '共通メソッド' do
    it_behaves_like '価格の表示'
    it_behaves_like '満足度の表示'
  end
end
