require "rails_helper"

RSpec.describe TaskMailer, type: :mailer do
  let(:task) { FactoryBot.create(:task, name: 'メイラーSpecを書く', description: '送信したメールの内容を確認します') }

  let(:text_body) do
    text_part = mail.body.parts.detect { |part| part.content_type == 'text/plain; charset=utf-8' }
    text_part.body.raw_source
  end

  let(:html_body) do
    html_part = mail.body.parts.detect { |part| part.content_type == 'text/html; charset=utf-8' }
    html_part.body.raw_source
  end

  describe '#creation_email' do
    let(:mail) { TaskMailer.creation_email(task) }

    it '想定通りのメールが生成されている' do
      expect(mail.subject).to eq('タスク作成完了メール')
      expect(mail.to).to eq(['user@example.com'])
    end
  end
end
