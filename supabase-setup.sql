-- 排课系统数据库表结构
-- 在 Supabase 的 SQL Editor 中运行这段代码

-- 创建存储应用数据的表
CREATE TABLE IF NOT EXISTS app_data (
  id TEXT PRIMARY KEY DEFAULT 'main',
  data JSONB NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 插入一条空记录（如果不存在）
INSERT INTO app_data (id, data)
VALUES ('main', '{"users":[],"teachers":[],"students":[],"courses":[]}')
ON CONFLICT (id) DO NOTHING;

-- 启用行级安全（RLS）
ALTER TABLE app_data ENABLE ROW LEVEL SECURITY;

-- 创建策略：允许所有操作（因为使用 secret key，但安全起见也加上）
CREATE POLICY "允许所有访问" ON app_data
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- 更新 updated_at 的触发器
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_app_data_updated_at
  BEFORE UPDATE ON app_data
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
